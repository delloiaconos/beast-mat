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

classdef OpenLoop < beast.Estimators.Estimator
    
    properties (Constant)
        %ExportableVars = { {'ClassVar', 'Size', 'ExportName', 'Save', 'FunctionHandler'} };
        ExportableVars = {
                {  'xPold', 'Nx', 'xP_all', true, '' }, ...
                {  'pPold', 'Np', 'pP_all', true, '' }, ...
            };
        FilterName = 'OpenLoop';
    end


    properties (SetAccess = immutable, GetAccess = private)   
        %private   : access by class members only (not from subclasses)
        %immutable : property can be set only in the constructor.  
        objModel;         
    end
    
    properties (SetAccess = immutable, GetAccess = public )
        Nx, Np, Nu, Ny;
    end
    
    properties (SetAccess = private, GetAccess = public)    
        deltat;
        
        told;

        xPold, pPold;
        
    end
    
    methods

        % Constructor
        function  obj = OpenLoop( objCellModel, DeltaT )         
            obj.objCell    = objCellModel;
            obj.deltat      = DeltaT;
        
            obj.Nx = objCellModel.Nx;
            obj.Np = objCellModel.Np;
            obj.Nu = objCellModel.Nu;
            obj.Ny = objCellModel.Ny;
        end
        
        function Initialize( obj, x0, p0, uold, yXPold, told )
            obj.told    = told;

            obj.xPold   = x0;
            obj.pPold   = p0;
            
            
        end
        
        function Step( obj, unew, yXPnew, tnew )
                MDobj = obj.objCell; % Useful copy
                
                xPnew= MDobj.f0( obj.xPold, obj.pPold, unew, obj.deltat );
                xPnew = MDobj.CoerceStateCompatibility( xPnew );
    
                obj.xPold   = xPnew;
                obj.told    = tnew;

        end
    end %methods

end %classdef Estimator_OpenLoop
