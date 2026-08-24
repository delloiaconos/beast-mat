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


classdef H0F0A < CellModels.CellModel
% x(1) <-> SOC
% y(1) <-> v
% p(1) <-> pR0 

%%

properties (Constant)
        Nx = 1; % soc
        Np = 1; % pR0
        Nu = 1;
        Ny = 1;
        
        Required = {'Qn_Ah', 'eta', 'soc', 'ocv0', 'ocv1' };
        
        Xnames = { 'SoC'};
        Pnames = { 'R0' };
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
                
        CoulombCountingConstant;
end
    
%%
methods

    % Initialization
    function obj = H0F0A( CellModelData, COV, deltat  )
        
        if( obj.CehckRequireds( CellModelData ) == true )
            
            obj.Qnom    = CellModelData.Qn_Ah*3600;
            obj.eta     = CellModelData.eta;
        
            obj.lutsoc  = CellModelData.soc;
            obj.lutocv0 = CellModelData.ocv0;
            obj.lutocv1 = CellModelData.ocv1;
            
            obj.CoulombCountingConstant = obj.eta*deltat/obj.Qnom;
        end
        
        if( obj.CeckCovariances( COV ) == true )
            
            obj.sxW = COV.sxW;
            obj.sxV = COV.sxV;
            obj.spR = COV.spR;
            obj.spE = COV.spE;
            
        end
        
    end
    
    % state update (600)
    function res = f0( obj, xold, pold, uold, deltat  )
        deltaSOC = obj.CoulombCountingConstant*uold(1,1);
    	res = xold-deltaSOC;
    end
        
    % output update (700)
    function res = g0( obj, xold, pold, uold, deltat  )
        ocv0old = interp1(obj.lutsoc,obj.lutocv0,xold(1));
        res = ocv0old -pold(1)*uold(1);
    end
    
    % derivative of f respect to x (611)
    function res = f1x( obj, xold, pold, uold, deltat   )
        res = 1.;
    end

    % derivative of f respect to p (612)
    function res = f1p( obj, xold, pold, uold, deltat   )
        res = 0.;
    end

    % derivative of g respect to x (711)
    function res = g1x( obj, xold, pold, uold, deltat   )
        res = interp1(obj.lutsoc,obj.lutocv1,xold(1));
    end
    
    % derivative of g respect to p (712)
    function res = g1p( obj, xold, pold, uold, deltat   )
        res = -uold(1);
    end
    
end % methods

methods(Static)    
    
    % CHECK Parameter Compatibility
    function pp = CoerceParsCompatibility( pp )
        if pp(1)<=0.
            pp(1) = CellModels.CellModel.zerohere;
            disp 'WARNING: H0F0A parameter p(1)=R0<0. CORRECTED TO ZERO'
        end
    end
    
    % CHECK State Compatibility
    function xx = CoerceStateCompatibility( xx )
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
        if CellModels.H0F0A.Nx ~= length(AA.x0)
            disp 'ERROR in CellModel - 10 Nx'
            pause
        end
        if CellModels.H0F0A.Np ~= length(AA.p0)
        	disp 'ERROR in CellModel - 20 Np'
            pause
        end
        if CellModels.H0F0A.Nu ~= length(AA.u_all(:,1))
            disp 'ERROR in CellModel - 30 Nu'
            pause
        end
    end%function    
    

    
end %methods( Static )
    
    
end




