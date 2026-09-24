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



classdef H0F0A < beast.CellModels.CellModel
%%
% u(1) <-> i (current oriented outwards on the + terminal, active sign convention)
% x(1) <-> SOC
% y(1) <-> v
% p(1) <-> pR0 
%%

properties(Constant)
    Nx = 1; 
    Np = 1;
    Nu = 1;
    Ny = 1;

    coeffNames = { "Qn_Ah", "eta", "soc", "ocv0", "ocv1" };
    xNames = { "SoC"};
    pNames = { "R0" };
    uNames = { "Icell" };
    yNames = { "Vcell" };
end


properties( SetAccess=immutable, GetAccess=public )
    Qnom;
    eta;

    lutsoc;
    lutocv0;
    lutocv1;

    deltatfix;

    sxW;
    sxV;
    spR;
    spE;
end

properties( Access = private)
    CoulombCountingConstant;
end 

methods( Access = public )

    % Constructor
    function obj = H0F0A( coefficients, cov, deltat )

        obj.checkContructor( coefficients, cov, deltat );

        obj.deltatfix  = deltat;

        if( obj.checkCoefficients( coefficients ) == true )
            obj.Qnom    = coefficients.Qn_Ah*3600;
            obj.eta     = coefficients.eta;
        
            obj.lutsoc  = coefficients.soc;
            obj.lutocv0 = coefficients.ocv0;
            obj.lutocv1 = coefficients.ocv1;

            % Calculated Coefficients
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
    	res = xold-deltaSOC;
    end
        
    function res = g0( obj, xold, pold, uold, deltat )
        ocv0old = interp1(obj.lutsoc,obj.lutocv0,xold(1));
        res = ocv0old -pold(1)*uold(1);
    end
    
    function res = f1x( obj, xold, pold, uold, deltat )
        res = 1.;
    end

    function res = f1p( obj, xold, pold, uold, deltat )
        res = 0.;
    end

    function res = g1x( obj, xold, pold, uold, deltat )
        res = interp1(obj.lutsoc,obj.lutocv1,xold(1));
    end
    
    function res = g1p( obj, xold, pold, uold, deltat )
        res = -uold(1);
    end
    
end

methods(Static)    
    
    % CHECK Parameter Compatibility
    function pp = coerceParameters( pp )
        if pp(1)<=0.
            pp(1) = beast.CellModels.CellModel.zerohere;
            disp 'WARNING: H0F0A parameter p(1)=R0<0. CORRECTED TO ZERO'
        end
    end
    
    % CHECK State Compatibility
    function xx = coerceState( xx )
        % TODO_020: Check State Consistency
        if xx(1,1)>1
            xx(1,1) = 1.;
            disp 'WARNING: H0F0A parameter x(1,1)=SOC>1. CORRECTED TO 1'
        elseif xx(1,1)<0
            xx(1,1) = 0.;
            disp 'WARNING: H0F0A parameter x(1,1)=SOC<0. CORRECTED TO 0'
        end
    end
    
    % CHECK Parameter Dimension Consistency
    function CellModelDimCheck( AA ) 
        if beast.CellModels.H0F0A.Nx ~= length(AA.x0)
            disp 'ERROR in CellModel - 10 Nx'
            pause
        end
        if beast.CellModels.H0F0A.Np ~= length(AA.p0)
        	disp 'ERROR in CellModel - 20 Np'
            pause
        end
        if beast.CellModels.H0F0A.Nu ~= length(AA.u_all(:,1))
            disp 'ERROR in CellModel - 30 Nu'
            pause
        end
    end    

end

end





