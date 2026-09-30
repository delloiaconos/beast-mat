% BEAST - Battery Estimation Algorithms and Simulation Toolkit
%
% This file is part of the BEAST MATLAB implementation.
%
% Project:
%   Battery Estimation Algorithms and Simulation Toolkit (BEAST)
%
% Repository:
%   https://github.com/delloiaconos/beast-mat
%
% Copyright (C) 2026 Salvatore Dello Iacono
% SPDX-License-Identifier: GPL-3.0-or-later
%
% See the LICENSE file in the project repository for license information.
%
% NOTE: Detailed file documentation is to be added as the implementation matures.


classdef R0R1C1R2C2 < beast.CellModels.CellModel
    % u(1) <-> i (current oriented outwards on the + terminal, active sign convention)
    % x(1,1) <-> SOC
    % x(2,1) <-> Vc1
    % y(1,1) <-> Vc2
    % p(1,1) <-> pR0 
    % p(2,1) <-> pR1 
    % p(3,1) <-> pC1 
    % p(4,1) <-> pR2 
    % p(5,1) <-> pC2 

    properties(Constant)
        Nx = 3;
        Np = 5; 
        Nu = 1;
        Ny = 1;
        
        coefficients = {"Qn_Ah", "eta", "soc", "ocv0", "ocv1"};
        
        states = { "SoC", "Vc1", "Vc2" };
        parameters = { "R0", "R1", "C1", "R2", "C2" };
        Inputs = { "Icell" };
        Outputs = { "Vcell" };
    end

    properties(Constant,GetAccess=protected)
        coefficientsBound   = { ...
                            Bounds( 0.0, NaN, true, false ), ...
                            Bounds( -1.0, 1.0, false, false ), ...
                            Bounds( 0.0, 1.0, false, false ), ...
                            Bounds( NaN, NaN, false, false ), ...
                            Bounds( NaN, NaN, false, false ) ...
                        };
        statesBound         = { ...
                            Bounds(0.0, 1.0, false, false), ...
                            Bounds(NaN, NaN, false, false), ...
                            Bounds(NaN, NaN, false, false) ...
                        };
        parametersBound     = { ...
                            Bounds(NaN, NaN, false, false), ...
                            Bounds(NaN, NaN, false, false), ...
                            Bounds(NaN, NaN, false, false), ...
                            Bounds(NaN, NaN, false, false), ...
                            Bounds(NaN, NaN, false, false) ...
                        };
    end

    properties(Access=public)
        Qnom;
        eta;

        lutsoc;
        lutocv0;
        lutocv1;
    end

    properties(Access=private)
        CoulombCountingConstant;
    end

    methods(Access=public)

        % Constructor
        function obj = R0R1C1R2C2( coeffs, cov, deltat  )
            obj@beast.CellModels.CellModel( coeffs, cov, deltat );
            
            if( obj.checkCoefficients( coeffs ) )
                obj.Qnom    = coeffs.Qn_Ah*3600;
                obj.eta     = coeffs.eta;
            
                obj.lutsoc  = coeffs.soc;
                obj.lutocv0 = coeffs.ocv0;
                obj.lutocv1 = coeffs.ocv1;
                
                obj.CoulombCountingConstant = obj.eta*obj.deltatfix/obj.Qnom;
            end

            if( obj.checkCovariances( cov ) == true )
                obj.sxW = cov.sxW;
                obj.sxV = cov.sxV;
                obj.spR = cov.spR;
                obj.spE = cov.spE;
            end
        end

        function res = f0( obj, xold, pold, uold, deltat )
            deltaSOC = obj.CoulombCountingConstant*uold(1,1);

            tau1    = pold(2,1)*pold(3,1);
            tau2    = pold(4,1)*pold(5,1);
            alpha1  = exp(-obj.deltatfix/tau1);
            alpha2  = exp(-obj.deltatfix/tau2);

            res(1,1) = xold(1,1)-deltaSOC;
            res(2,1) = alpha1*xold(2,1)+pold(2,1)*(alpha1-1.)*uold(1,1);
            res(3,1) = alpha2*xold(3,1)+pold(4,1)*(alpha2-1.)*uold(1,1);
        end
        
        function res = g0( obj, xold, pold, uold, deltat )
            ocv0old  = interp1(obj.lutsoc,obj.lutocv0,xold(1,1));
            res(1,1) = ocv0old - pold(1,1)*uold(1,1) + xold(2,1) + xold(3,1);
        end
        
        function res = f1x( obj, xold, pold, uold, deltat )
            tau1     = pold(2,1)*pold(3,1);
            tau2     = pold(4,1)*pold(5,1);
            alpha1   = exp(-obj.deltatfix/tau1);
            alpha2   = exp(-obj.deltatfix/tau2);

            res(1,1) = 1.;
            res(1,2) = 0.;
            res(1,3) = 0.;
            
            res(2,1) = 0.;
            res(2,2) = alpha1;
            res(2,3) = 0.;
            
            res(3,1) = 0.;
            res(3,2) = 0.;
            res(3,3) = alpha2;
        end

        function res = f1p( obj, xold, pold, uold, deltat )
            tau1     = pold(2,1)*pold(3,1);
            tau2     = pold(4,1)*pold(5,1);
            alpha1   = exp(-obj.deltatfix/tau1);
            alpha2   = exp(-obj.deltatfix/tau2);
            adtrc1   = alpha1*obj.deltatfix/tau1;
            adtrc2   = alpha2*obj.deltatfix/tau2;

            res(1,1) = 0.;
            res(1,2) = 0.;
            res(1,3) = 0.;
            res(1,4) = 0.;
            res(1,5) = 0.;
            
            res(2,1) = 0.;
            res(2,2) = adtrc1/pold(2,1)*xold(2,1)+(alpha1-1.+adtrc1)*uold(1,1);
            res(2,3) = adtrc1/pold(3,1)*(xold(2,1)+pold(2,1)*uold(1,1));
            res(2,4) = 0.;
            res(2,5) = 0.;
            
            res(3,1) = 0.;
            res(3,2) = 0.;
            res(3,3) = 0.;
            res(3,4) = adtrc2/pold(4,1)*xold(3,1)+(alpha2-1.+adtrc2)*uold(1,1);
            res(3,5) = adtrc2/pold(5,1)*(xold(3,1)+pold(4,1)*uold(1,1));
        end

        function res = g1x( obj, xold, pold, uold, deltat )
            res(1,1) = interp1(obj.lutsoc,obj.lutocv1,xold(1,1));
            res(1,2) = 1.;
            res(1,3) = 1.;
        end
        
        function res = g1p( obj, xold, pold, uold, deltat )
            res(1,1) = -uold(1,1);
            res(1,2) = 0.;
            res(1,3) = 0.;
            res(1,4) = 0.;
            res(1,5) = 0.;
        end

    end

end
