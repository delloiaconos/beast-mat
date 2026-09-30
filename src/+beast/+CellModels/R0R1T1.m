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

classdef R0R1T1 < beast.CellModels.CellModel
    % u(1) <-> i (current oriented outwards on the + terminal, active sign convention)
    % deltat FIXED
    % R = B1/(A1-1)
    % tau = -deltat/log(A1)
    % C = R/tau
    % x(1,1) <-> SOC
    % x(2,1) <-> vC
    % y(1,1) <-> v
    % p(1,1) <-> pR0 
    % p(2,1) <-> pR1 
    % p(3,1) <-> ptau1 

    properties(Constant)
        Nx = 2; % soc, vc1
        Np = 3; % R0, R1, C1
        Nu = 1;
        Ny = 1;
        
        coefficients = {"Qn_Ah", "eta", "soc", "ocv0", "ocv1"};
        
        states = { "SoC", "V1" };
        parameters = { "R0", "R1", "tau1" };
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
        statesBound         = {
                            Bounds(0.0, 1.0, false, false), ...
                            Bounds(NaN, NaN, false, false) ...
                        };
        parametersBound     = { ...
                            Bounds(NaN, NaN, false, false), ...
                            Bounds(NaN, NaN, false, false), ...
                            Bounds(NaN, NaN, false, false) ...
                        };
    end

    properties(Access=public)
        Qnom_Ah;
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
        
        function obj = R0R1T1( coeffs, cov, deltat )
            obj@beast.CellModels.CellModel( coeffs, cov, deltat );
            
            if( obj.checkCoefficients( coeffs ) == true )
                obj.Qnom_Ah = coeffs.Qn_Ah;
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
            alphaloc = exp(-obj.deltatfix/pold(3,1));
            res(1,1) = xold(1,1)-deltaSOC;
            res(2,1) = alphaloc*xold(2,1)+pold(2,1)*(alphaloc-1.)*uold(1,1);
        end

        function res = g0( obj, xold, pold, uold, deltat )
            ocv0old = interp1(obj.lutsoc,obj.lutocv0,xold(1,1));
            res(1,1) = ocv0old -pold(1,1)*uold(1,1)+xold(2,1);
        end
        
        function res = f1x( obj, xold, pold, uold, deltat )
            alphaloc = exp(-obj.deltatfix/pold(3,1));
            res(1,1) = 1.;
            res(1,2) = 0.;
            res(2,1) = 0.;
            res(2,2) = alphaloc ;
        end
        
        function res = f1p( obj, xold, pold, uold, deltat )
            alphaloc = exp(-obj.deltatfix/pold(3,1));
            adtrc2 = alphaloc*obj.deltatfix/pold(3,1)/pold(3,1);
            res(1,1) = 0.;
            res(1,2) = 0.;
            res(1,3) = 0.;
            res(2,1) = 0.;
            res(2,2) = (alphaloc-1.)*uold(1,1);
            res(2,3) = adtrc2*(xold(2,1)+pold(2,1)*uold(1,1));
        end

        function res = g1x( obj, xold, pold, uold, deltat )
            res(1,1) = interp1(obj.lutsoc,obj.lutocv1,xold(1,1));
            res(1,2) = 1.;
        end

        function res = g1p( obj, xold, pold, uold, deltat )
            res(1,1) = -uold(1,1);
            res(1,2) = 0.;
            res(1,3) = 0.;
        end
        
    end

end

