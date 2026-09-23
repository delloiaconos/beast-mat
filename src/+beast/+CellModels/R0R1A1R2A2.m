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


classdef R0R1A1R2A2 < beast.CellModels.CellModel

%%
% x(1,1) <-> SOC
% x(2,1) <-> vC
% y(1,1) <-> v
% p(1,1) <-> pR0 
% p(2,1) <-> pR1 
% p(3,1) <-> pC1 
% p(4,1) <-> pR2 
% p(5,1) <-> pC2 
%%

properties (Constant)
        Nx = 3; % soc, vc1, vc2
        Np = 5; % R0, R1, C1, R2, C2
        Nu = 1;
        Ny = 1;
        
        Required = {'Qn_Ah', 'eta', 'soc', 'ocv0', 'ocv1'};
        
        Xnames = { 'SoC', 'V1', 'V2' };
        Pnames = { 'R0', 'R1', 'A1', 'R2', 'A2' };
        Unames = { 'Icell' };
        Ynames = { 'Vcell' };
end %properties (Constant)

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
end %properties

properties (Access = private)
        CoulombCountingConstant;
end %properties (Access = private)

%%
methods

    % Initialization
    function obj = R0R1A1R2A2( CellModelData, COV, deltat  )
        
        obj.deltatfix = deltat;
        
        if( obj.CheckRequireds( CellModelData ) == true )
            
            obj.Qnom    = CellModelData.Qn_Ah*3600;
            obj.eta     = CellModelData.eta;
        
            obj.lutsoc  = CellModelData.soc;
            obj.lutocv0 = CellModelData.ocv0;
            obj.lutocv1 = CellModelData.ocv1;
            
            obj.CoulombCountingConstant = obj.eta*obj.deltatfix/obj.Qnom;
            
        end
        
		if( obj.CheckCovariances( COV ) == true )
            
            obj.sxW = COV.sxW;
            obj.sxV = COV.sxV;
            obj.spR = COV.spR;
            obj.spE = COV.spE;
            
        end
        
    end

    % state update {Nx,1} = {3,1}
    function res = f0( obj, xold, pold, uold, deltat )
        deltaSOC = obj.CoulombCountingConstant*uold(1,1);

        alpha1  = pold(3,1);
        alpha2  = pold(5,1);

        res(1,1) = xold(1,1)-deltaSOC;
        res(2,1) = alpha1*xold(2,1)+pold(2,1)*(alpha1-1.)*uold(1,1);
        res(3,1) = alpha2*xold(3,1)+pold(4,1)*(alpha2-1.)*uold(1,1);
    end
        
    % output update {Ny,1} = {1,1}
    function res = g0( obj, xold, pold, uold, deltat )
        ocv0old  = interp1(obj.lutsoc,obj.lutocv0,xold(1,1));
        res(1,1) = ocv0old - pold(1,1)*uold(1,1) + xold(2,1) + xold(3,1);
    end
    
    % derivative of f respect to x {Nx, Nx} = {3,3}
    function res = f1x( obj, xold, pold, uold, deltat )
        
        alpha1   = pold(3,1);
        alpha2   = pold(5,1);

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

    % derivative of f respect to p {Nx, Np} = {3,5}
    function res = f1p( obj, xold, pold, uold, deltat )
        
        alpha1   = pold(3,1);
        alpha2   = pold(5,1);
        tau1     = - obj.deltatfix/ log( alpha1 );
        tau2     = - obj.deltatfix/ log( alpha2 );
        
        adtrc1   = alpha1*obj.deltatfix/tau1;
        adtrc2   = alpha2*obj.deltatfix/tau2;

        res(1,1) = 0.;
        res(1,2) = 0.;
        res(1,3) = 0.;
        res(1,4) = 0.;
        res(1,5) = 0.;
        
        res(2,1) = 0.;
        res(2,2) = adtrc1/pold(2,1)*xold(2,1)+(alpha1-1.+adtrc1)*uold(1,1);
        res(2,3) = xold(2,1)+pold(2,1)*uold(1,1);%adtrc1/pold(3,1)*(xold(2,1)+pold(2,1)*uold(1,1));
        res(2,4) = 0.;
        res(2,5) = 0.;
        
        res(3,1) = 0.;
        res(3,2) = 0.;
        res(3,3) = 0.;
        res(3,4) = adtrc2/pold(4,1)*xold(3,1)+(alpha2-1.+adtrc2)*uold(1,1);
        res(3,5) = xold(3,1)+pold(4,1)*uold(1,1);%adtrc2/pold(5,1)*(xold(3,1)+pold(4,1)*uold(1,1));
    
    end

    % derivative of g respect to x {Ny, Nx} = {1,3}
    function res = g1x( obj, xold, pold, uold, deltat )
        res(1,1) = interp1(obj.lutsoc,obj.lutocv1,xold(1,1));
        res(1,2) = 1.;
        res(1,3) = 1.;
    end
    
    % derivative of g respect to p {Ny, Np} = {1,5}
    function res = g1p( obj, xold, pold, uold, deltat )
        res(1,1) = -uold(1,1);
        res(1,2) = 0.;
        res(1,3) = 0.;
        res(1,4) = 0.;
        res(1,5) = 0.;
    end
    

end % methods

methods(Static)        
    
    % CHECK Parameter Compatibility
    function pp = coerceParameters( pp )
        if pp(1,1)<=0.
            pp(1,1) = beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0R1A1R2A2 - parameter p(1,1)=R0<=0 CORRECTED TO ZERO'
        end
        if pp(2,1)<=0.
            pp(2,1) = beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0R1A1R2A2 - parameter p(2,1)=R1<=0 CORRECTED TO ZERO';
        end
        if pp(3,1)<=0.
            pp(3,1) = beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0R1A1R2A2 - parameter p(3,1)=Alpha1<=0 CORRECTED TO ZERO'
        elseif pp(3,1)>=1.
            pp(3,1) = 1-beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0R1A1R2A2 - parameter p(3,1)=Alpha1>=1 CORRECTED TO 1-ZERO'
        end
        if pp(4,1)<=0.
            pp(4,1) = beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0R1A1R2A2 - parameter p(4,1)=R2<=0 CORRECTED TO ZERO';
        end
        if pp(5,1)<=0.
            pp(5,1) = beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0R1A1R2A2 - parameter p(5,1)=Alpha2<=0 CORRECTED TO ZERO'
        elseif pp(5,1)>=1.
            pp(5,1) = 1-beast.CellModels.CellModel.zerohere;
            disp 'WARNING: R0R1A1R2A2 - parameter p(5,1)=Alpha2>=1 CORRECTED TO 1-ZERO'
        end
    end
    
    
    % CHECK State Compatibility
    function xx = coerceState( xx )
        % TODO_020: Check State Consistency
        if xx(1,1)>1
            xx(1,1) = 1.;
            disp 'WARNING: R0R1A1R2A2 - parameter x(1,1)=SOC>1. CORRECTED TO 1'
        elseif xx(1,1)<0
            xx(1,1) = 0.;
            disp 'WARNING: R0R1A1R2A2 - parameter x(1,1)=SOC<0. CORRECTED TO 0'
        end
    end
    
    % CHECK Parameter Dimension Consistency
    function checkCellModelDim( AA )
        if beast.CellModels.R0R1A1R2A2.Nx ~= length(AA.x0)
            disp 'ERROR: R0R1A1R2A2 - 10 Nx'
            pause
        end
        if beast.CellModels.R0R1A1R2A2.Np ~= length(AA.p0)
        	disp 'ERROR: R0R1A1R2A2 - 20 Np'
            pause
        end
        if beast.CellModels.R0R1A1R2A2.Nu ~= length(AA.u_all(:,1))
            disp 'ERROR: R0R1A1R2A2 - 30 Nu'
            pause
        end
    end

end    
    
    
end




