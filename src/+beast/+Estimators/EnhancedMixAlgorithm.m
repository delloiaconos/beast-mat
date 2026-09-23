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

classdef EnhancedMixAlgorithm < beast.Estimators.Estimator

    properties(Constant)
        ExportableVars = {
                {  'xPold', 'Nx', 'xP_all', true, '' }, ...
                {  'pPold', 'Np', 'pP_all', true, '' }, ...
            };
        FilterName = 'Enhanced Mix Algorithm';
    end


    properties(SetAccess=immutable, GetAccess=private)   
        objCell; 
        deltat;
    end
    
    properties(SetAccess=immutable, GetAccess=public)
        Nx; Np; Nu; Ny;
    end

    properties(SetAccess=private, GetAccess=public)
        told;

        xPold; 
        pPold;
        
        Lxold; 
        Lpold;
    end
    
    methods(Access=public)

        % Constructor
        function  obj = EnhancedMixAlgorithm( objCellModel, DeltaT )
                  
            obj.objCell    = objCellModel;
            obj.deltat      = DeltaT;
        
            obj.Nx = objCellModel.Nx;
            obj.Np = objCellModel.Np;
            obj.Nu = objCellModel.Nu;
            obj.Ny = objCellModel.Ny;
     
        end
        
        function initialize( obj, x0, p0, uold, yXPold, told )
            obj.told    = told;            
            
            obj.xPold   = x0;
            obj.pPold   = p0;
            
            obj.Lxold   = 1e5*diag( obj.objCell.sxW );
            obj.Lpold   = 1e5*diag( obj.objCell.sxV );
        end
  
        function step( obj, unew, yXPnew, tnew )
            MDobj = obj.objCell; % Useful copy
            
            xMnew = MDobj.f0( obj.xPold, obj.pPold, unew, obj.deltat );
	
            g0new = MDobj.g0( xMnew, obj.pPold, unew, obj.deltat );
            
            err = yXPnew - g0new;
    
            xPnew = xMnew + obj.Lxold*err;
            xPnew = MDobj.coerceState( xPnew );
    
            % ATTENZIONE!!! Non e' generico, migliorare il calcolo del guadagno!
            pPnew = obj.pPold + obj.Lpold*err*sign( unew );
            pPnew = MDobj.coerceParameters( pPnew );
    
            obj.told    = tnew;
            obj.pPold   = pPnew;
            obj.xPold   = xPnew;
        end
    
    end
    
end

    
    
