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


classdef MixAlgorithm < beast.Estimators.Estimator
    
    properties(Constant)
        ExportableVars = {
                {  "xPold", "Nx", "xP_all", true, '' }, ...
                {  "pPold", "Np", "pP_all", true, '' }, ...
                {  "Lxold", "Nx", "Lx_all", true, '' }, ...                
            };
        
        FilterName = 'Mix Algorithm';
    end

    
    properties(SetAccess = immutable, GetAccess = public)
        Nx; Np; Nu; Ny;
    end
    
    properties(SetAccess = private, GetAccess = public)      
        told;
        %uold;
        
        %yXPold;

        xPold, pPold;
        %xMold;
        
        Lxold;
    end
    
    methods(Access=public)
        % Constructor
        function  obj = MixAlgorithm( objCellModel, deltat )
            obj@beast.Estimators.Estimator( objCellModel, deltat );        
       
            obj.Nx = objCellModel.Nx;
            obj.Np = objCellModel.Np;
            obj.Nu = objCellModel.Nu;
            obj.Ny = objCellModel.Ny;
        end
        
        function initialize( obj, x0, p0, uold, yXPold, told )
            obj.told    = told;
            %obj.uold    = uold;
            
            %obj.yXPold  = yXPold;
            obj.xPold   = x0;
            obj.pPold   = p0;
            %obj.xMold   = x0;
            obj.Lxold   = zeros( obj.Nx, obj.Ny );
            
            if( length( diag( obj.objCell.sxW ) ) ~= obj.Nx )
                dispError( 'ESTIMATOR MixAlgorithm ERROR!' );
                pause();
            end
            
            obj.Lxold   = 1e5*diag( obj.objCell.sxW );
        end
        
        function step( obj, unew, yXPnew, tnew )
            MDobj = obj.objCell; % Useful copy
            
            xMnew = MDobj.f0( obj.xPold, obj.pPold, unew, obj.deltat );

            g0new = MDobj.g0( xMnew, obj.pPold, unew, obj.deltat );
            
            Lxnew = obj.Lxold;
            
            xcorr = Lxnew*(yXPnew - g0new);

            xPnew = xMnew + xcorr;
            xPnew = MDobj.coerceState( xPnew );

            obj.xPold   = xPnew;
            obj.told    = tnew;
            %xP_all(:,kk)  = xPold;    

            %% PREPARING FOR NEXT STEP
            obj.Lxold = Lxnew; %NO change!
        end
    end 

end
