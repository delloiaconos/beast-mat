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


classdef R0R1C1 < beast.CellModels.CellModel
%%
% u(1) <-> i (current oriented outwards on the + terminal, active sign convention)
% deltat FIXED
% R = B1/(A1-1)
% tau = -deltat/log(A1)
% C = R/tau  
% x(1,1) <-> SOC
% x(2,1) <-> Vc1
% y(1,1) <-> V
% p(1,1) <-> pR0 
% p(2,1) <-> pR1 
% p(3,1) <-> pC1 
%%

properties(Constant)
    Nx = 2;
    Np = 3; 
    Nu = 1;
    Ny = 1;
    
    Coefficients = {"Qn_Ah", "eta", "soc", "ocv0", "ocv1"};
    
    Xnames = { "SoC", "Vc1" };
    Pnames = { "R0", "R1", "C1" };
    Unames = { "Icell" };
    Ynames = { "Vcell" };
end

properties(Access=public)
    Qnom;
    eta;

    lutsoc;
    lutocv0;
    lutocv1;

    sxW;
    sxV;
    spR;
    spE;
    
    deltatfix;
end

properties(Access=private)
    CoulombCountingConstant;
end

methods(Access=public)

    % Initialization
    function obj = R0R1C1( coefficients, cov, deltat )
    	
        obj.deltatfix = deltat;
        
        if( obj.checkCoefficients( coefficients ) == true )
            obj.Qnom    = coefficients.Qn_Ah*3600;
            obj.eta     = coefficients.eta;
        
            obj.lutsoc  = coefficients.soc;
            obj.lutocv0 = coefficients.ocv0;
            obj.lutocv1 = coefficients.ocv1;
            
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
        tauloc   = pold(2,1)*pold(3,1);
        alphaloc = exp(-obj.deltatfix/tauloc);
        res(1,1) = xold(1,1)-deltaSOC;
        res(2,1) = alphaloc*xold(2,1)+pold(2,1)*(alphaloc-1.)*uold(1,1);
    end
        
    function res = g0( obj, xold, pold, uold, deltat )
        ocv0old  = interp1(obj.lutsoc,obj.lutocv0,xold(1,1));
        res(1,1) = ocv0old -pold(1,1)*uold(1,1)+xold(2,1);
    end
    
    function res = f1x( obj, xold, pold, uold, deltat )
        tauloc   = pold(2,1)*pold(3,1);
        alphaloc = exp(-obj.deltatfix/tauloc);
        res(1,1) = 1.;
        res(1,2) = 0.;
        res(2,1) = 0.;
        res(2,2) = alphaloc ;
    end

    function res = f1p( obj, xold, pold, uold, deltat )
        tauloc   = pold(2,1)*pold(3,1);
        alphaloc = exp(-obj.deltatfix/tauloc);
        adtrc    = alphaloc*obj.deltatfix/tauloc;
        res(1,1) = 0.;
        res(1,2) = 0.;
        res(1,3) = 0.;
        res(2,1) = 0.;
        res(2,2) = adtrc/pold(2,1)*xold(2,1)+(alphaloc-1.+adtrc)*uold(1,1);
        res(2,3) = adtrc/pold(3,1)*(xold(2,1)+pold(2,1)*uold(1,1));
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

methods(Static)        
    
    % CHECK Parameter Compatibility
    function pp = coerceParameters( pp )
        if pp(1,1)<=0.
            pp(1,1) = beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0R1C1 parameter p(1,1)=R0<=0 CORRECTED TO ZERO'
        end
        if pp(2,1)<=0.
            pp(2,1) = beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0R1C1 parameter p(2,1)=R1<=0 CORRECTED TO ZERO';
        end
        if pp(3,1)<=0.
            pp(3,1) = beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0R1C1 parameter p(3,1)=C1<=0 CORRECTED TO ZERO'
        end
    end
    
    % CHECK State Compatibility
    function xx = coerceState( xx )
        % TODO_020: Check State Consistency
        if xx(1,1)>1
            xx(1,1) = 1.;
            disp 'WARNING: R0R1C1 parameter x(1,1)=SOC>1. CORRECTED TO 1'
        elseif xx(1,1)<0
            xx(1,1) = 0.;
            disp 'WARNING: R0R1C1 parameter x(1,1)=SOC<0. CORRECTED TO 0'
        end
    end
    
    % CHECK Parameter Dimension Consistency
    function checkCellModelDim( AA )
        if beast.CellModels.R0R1C1.Nx ~= length(AA.x0)
            disp 'ERROR in CellModel - 10 Nx'
            pause
        end
        if beast.CellModels.R0R1C1.Np ~= length(AA.p0)
        	disp 'ERROR in CellModel - 20 Np'
            pause
        end
        if beast.CellModels.R0R1C1.Nu ~= length(AA.u_all(:,1))
            disp 'ERROR in CellModel - 30 Nu'
            pause
        end
    end
    
end    
    
end



