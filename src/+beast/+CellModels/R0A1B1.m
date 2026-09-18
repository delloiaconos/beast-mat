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


% u(1) <-> i (current oriented outwards on the + terminal, active sign convention)


classdef R0A1B1 < beast.CellModels.CellModel
    % deltat FIXED
    
% x(1,1) <-> SOC
% x(2,1) <-> vC
% y(1,1) <-> v
% p(1,1) <-> pR0 
% p(2,1) <-> pA1 
% p(3,1) <-> pB1 
%              R = B1/(A1-1)
%              tau = -deltat/log(A1)
%              C = R/tau
%
%%

properties (Constant)
        Nx = 2; % soc, vc1
        Np = 3; % R0, A1, B1
        Nu = 1;
        Ny = 1;
        
        Required = {'Qn_Ah', 'eta', 'soc', 'ocv0', 'ocv1'};
        
        Xnames = { 'SoC', 'V1' };
        Pnames = { 'R0', 'A1', 'B1' };
        Unames = { 'Icell' };
        Ynames = { 'Vcell' };
end

properties
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
        CoulombCountingConstant;
end
    
%%
methods

    % Initialization
    function obj = R0A1B1( CellModelData, COV, deltat  )
        
        obj.deltatfix = deltat;
        
        if( obj.CheckRequireds( CellModelData ) == true )
    	
            obj.Qnom    = CellModelData.Qn_Ah*3600;
            obj.eta     = CellModelData.eta;
        
            obj.lutsoc  = CellModelData.soc;
            obj.lutocv0 = CellModelData.ocv0;
            obj.lutocv1 = CellModelData.ocv1;
            
            obj.CoulombCountingConstant = obj.eta*obj.deltatfix /obj.Qnom;
        end
        
        if( obj.CheckCovariances( COV ) == true )
            
            obj.sxW = COV.sxW;
            obj.sxV = COV.sxV;
            obj.spR = COV.spR;
            obj.spE = COV.spE;
            
        end
       
    end
    
    % state update (600)
    function res = f0( obj, xold, pold, uold, deltat   )
        deltaSOC = obj.CoulombCountingConstant*uold(1,1);
    	res(1,1) = xold(1,1)-deltaSOC;
        res(2,1) = pold(2,1)*xold(2,1)+pold(3,1)*uold;
    end
        
    % output update (700)
    function res = g0( obj, xold, pold, uold, deltat   )
        ocv0old = interp1(obj.lutsoc,obj.lutocv0,xold(1,1));
        res(1,1) = ocv0old -pold(1,1)*uold(1,1)+xold(2,1);
    end
    
    % derivative of f respect to x (611)
    function res = f1x( obj, xold, pold, uold, deltat   )
        res(1,1) = 1.;
        res(1,2) = 0.;
        res(2,1) = 0.;
        res(2,2) = pold(2,1);
    end
    
    % derivative of f respect to p (612)
    function res = f1p( obj, xold, pold, uold, deltat   )
        res(1,1) = 0.;
        res(1,2) = 0.;
        res(1,3) = 0.;
        res(2,1) = 0.;
        res(2,2) = xold(2,1);
        res(2,3) = uold;
    end

    % derivative of g respect to x (711)
    function res = g1x( obj, xold, pold, uold, deltat   )
        res(1,1) = interp1(obj.lutsoc,obj.lutocv1,xold(1,1));
        res(1,2) = 1.;
    end
    
    % derivative of g respect to p (712)
    function res = g1p( obj, xold, pold, uold, deltat   )
        res(1,1) = -uold(1,1);
        res(1,2) = 0.;
        res(1,3) = 0.;
    end
    

    
end % methods


methods(Static)    

    % CHECK Parameter Compatibility
    function pp = CoerceParsCompatibility( pp )
        if pp(1,1)<=0.
            pp(1,1) = beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0A1B1 parameter p(1,1)=R0<=0 CORRECTED TO ZERO'
        end
        if pp(2,1)<=0.
            pp(2,1) = beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0A1B1 parameter p(2,1)=A1<=0 CORRECTED TO ZERO';
        elseif pp(2,1)>1.
            pp(2,1) = 1.;
            disp 'WARNING: R0A1B1 parameter p(2,1)=A1>1 CORRECTED TO ONE';
        end
        if pp(3,1)>=0.
            pp(3,1) = -beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0A1B1 parameter p(3,1)=B1>=0 CORRECTED TO -ZERO'
        end
    end

    
    % CHECK State Compatibility
    function xx = CoerceStateCompatibility( xx )
        % TODO_020: Check State Consistency
        if xx(1,1)>1
            xx(1,1) = 1.;
            disp 'WARNING: R0A1B1 parameter x(1,1)=SOC>1. CORRECTED TO 1'
        elseif xx(1,1)<0
            xx(1,1) = 0.;
            disp 'WARNING: R0A1B1 parameter x(1,1)=SOC<0. CORRECTED TO 0'
        end
    end
    
    
    % CHECK Parameter Dimension Consistency
    function CheckCellModelDim( AA );
        if beast.CellModels.R0A1B1.Nx ~= length(AA.x0)
            disp 'ERROR in CellModel - 10 Nx'
            pause
        end
        if beast.CellModels.R0A1B1.Np ~= length(AA.p0)
        	disp 'ERROR in CellModel - 20 Np'
            pause
        end
        if beast.CellModels.R0A1B1.Nu ~= length(AA.u_all(:,1))
            disp 'ERROR in CellModel - 30 Nu'
            pause
        end
    end%function    
    

    
end    
    
    
end




