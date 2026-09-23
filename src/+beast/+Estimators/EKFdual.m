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

classdef EKFdual < beast.Estimators.Estimator

    properties (Constant)
        %ExportableVars = { {'ClassVar', 'Size', 'ExportName', 'Save', 'FunctionHandler'} };
        ExportableVars = {
                { 'xPold'  , 'Nx', 'xP_all' , true, '' }, ...
                { 'pPold'  , 'Np', 'pP_all' , true, '' }, ...
                { 'Lxold'  , 'Nx', 'Lx_all' , true, '' }, ...
                { 'Lpold'  , 'Np', 'Lp_all' , true, '' }, ...
                { 'sxPold' , 'Nx', 'sxP_all', true, @diag }, ...
                { 'spPold' , 'Np', 'spP_all', true, @diag }, ...
                { 'dyold'  , '1' , 'dy_all' , true, '' }, ...
                { 'xPold'  , '1' , 'SoC'    , true, @(x) ( x(1) ) }
            };
        
        FilterName = 'Enhanced Dual Kalman Filter';
    end

    properties (SetAccess = immutable, GetAccess = protected)   
        eyeNp, eyeNx;
    end
    
    properties( SetAccess = public, GetAccess = public )
        objCell; 
    end
    
    properties (SetAccess = immutable, GetAccess = public )
        Nx, Np, Nu, Ny;
    end
    
    properties (SetAccess = protected, GetAccess = public)
        deltat;

        told;
        uold;
        
        yXPold;

        xPold, pPold;
        
        sxPold, spPold;
        
        Lxold, Lpold;
        
        dxMdpold;
        dgdpold;
        dyold;
    end
    
    
    methods     
        % Constructor
        function  obj = EKFdual( objCellModel, DeltaT )
            
            obj.objCell    = objCellModel;
            obj.deltat      = DeltaT;
        
            obj.Nx = objCellModel.Nx;
            obj.Np = objCellModel.Np;
            obj.Nu = objCellModel.Nu;
            obj.Ny = objCellModel.Ny;
     
            obj.eyeNp = eye( obj.Np );
            obj.eyeNx = eye( obj.Nx );
            
                        
            obj.spPold      = zeros( obj.Np);  
            obj.sxPold      = zeros( obj.Nx);

            obj.dxMdpold    = zeros( obj.Nx, obj.Np);
            %obj.dxPdpold    = zeros( obj.Nx, obj.Np);
            obj.dgdpold     = zeros( obj.Ny, obj.Np);

            obj.Lpold   = zeros( obj.Np, obj.Ny );
            obj.Lxold   = zeros( obj.Nx, obj.Ny ); 
        end
        
        function initialize( obj, x0, p0, uold, yXPold, told )
            MDobj = obj.objCell; % Useful copy
            
            obj.told    = told;
            obj.uold    = uold;
            
            obj.yXPold  = yXPold;
            obj.xPold   = x0;
            %obj.xMold   = x0;
            
            obj.pPold   = p0;
            %obj.pMold   = p0;
            
            yMnew       = MDobj.g0( x0, p0, uold, obj.deltat );
            obj.yXPold  = yMnew;
            obj.dyold   = yXPold - yMnew;
        end
        
        function step( obj, unew, yXPnew, tnew )
            MDobj = obj.objCell; % Useful copy
            
            %% (1/XX) PARAMETER - estimate time update
            pMnew = obj.pPold;                
            
            
            %% (2/XX) PARAMETER - error covariance time update     
            spMnew  = obj.spPold + MDobj.spR;          
            
    
            %% (3/XX) STATE - estimate time update
            xMnew = MDobj.f0( obj.xPold, pMnew, obj.uold, obj.deltat );
            xMnew = MDobj.coerceState( xMnew );
          
        
            %% (4/XX) STATE - error covariance time update
            f1xold = MDobj.f1x( obj.xPold, pMnew, obj.uold, obj.deltat ); % matrix A(k-1)
            sxMnew  = f1xold* obj.sxPold *f1xold.' + MDobj.sxW;          
            
            %% (5/XX) STATE - Kalman gain computation
            g1xnew = MDobj.g1x( xMnew, pMnew, unew, obj.deltat ); % matrix Cx(k)
            tmp1  = g1xnew*sxMnew*g1xnew.';
            tmp2  = tmp1 + MDobj.sxV;                        
            Lxnew = sxMnew*(g1xnew.')/tmp2; %Kalman gain matrix    
            %Lx_all(:,kk) = Lxnew; (posso sostituire con Lxold)
    
            %% (6/XX) STATE - estimate measurement update
            g0new = MDobj.g0( xMnew, pMnew, unew, obj.deltat ); 
            dynew = yXPnew - g0new;
            xcorr = Lxnew*dynew;
            
            xPnew = xMnew + xcorr;
            xPnew = MDobj.coerceState( xPnew );
    
            %% (7/XX) STATE - error covariance measurement update
            sxPnew = (obj.eyeNx - Lxnew*g1xnew)*sxMnew;                   %
            

            %% (8/XX) PARAMETER - Kalman gain computation
            g1pnew = MDobj.g1p( xMnew, pMnew, unew, obj.deltat ); 
            f1pold = MDobj.f1p( obj.xPold, pMnew, obj.uold, obj.deltat );
            % f1xold, g1xnew ALREADY COMPUTED
            dxPdpold = obj.dxMdpold - obj.Lxold*obj.dgdpold;
            dxMdpnew = f1pold + f1xold*dxPdpold;
            dgdpnew  = g1pnew + g1xnew*dxMdpnew; % CCpnew = dgdpnew = Ctheta(k)
            tmp1  = dgdpnew*spMnew*dgdpnew.';
            tmp2  = tmp1 + MDobj.spE;                        
            Lpnew = spMnew*(dgdpnew.')/tmp2;    
            
    
            %% (9/XX) PARAMETER - estimate measurement update
            % g0new GIA' CALCOLATO. Ma non si deve usare il seguente?
            % g0new = MDobj.g0( xPnew, pMnew, unew );
            pcorr = Lpnew*dynew;
            pPnew = pMnew + pcorr;
    
            % correction to avoid negative parameters
            pPnew = MDobj.coerceParameters( pPnew );                                  

            %% (10/XX) PARAMETERS - error covariance measurement update
            spPnew = ( obj.eyeNp - Lpnew*dgdpnew )*spMnew;                   %
    
            %% PREPARING FOR NEXT STEP
            obj.told   = tnew;
            obj.uold   = unew;
            obj.yXPold = yXPnew;

            
            obj.xPold    = xPnew;
            obj.pPold    = pPnew;
            
            obj.sxPold   = sxPnew;
            obj.spPold   = spPnew; 

            obj.Lxold    = Lxnew;
            obj.Lpold    = Lpnew;
            
            obj.dxMdpold = dxMdpnew;
            obj.dgdpold  = dgdpnew;
            obj.dyold    = dynew;
        end
        
    end %methods
    
end %classdef

    
