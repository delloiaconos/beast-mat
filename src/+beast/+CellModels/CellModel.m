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

classdef CellModel
    %CELLMODEL Super Class fot all cell model class implementations.
    
    properties(Constant, Access=public)
        Covariances = { "sxW", "sxV", "spE", "spR" }; 
    end

    properties(Constant, Abstract)
        Nx;
        Np;
        Nu;
        Ny;
        
        coeffNames;
        xNames;
        pNames;
        uNames;
        yNames;
    end
    
    properties(Constant)
        zerohere = 1.e-9;
    end
    
    methods(Access=protected)

        function obj = CellModel( coeffs, cov, deltat )

            if isa( deltat, 'duration' )
                deltat = seconds( deltat );
            end
            if( isreal( deltat ) && ~isnan( deltat ) && ...
                ( deltat > 0 ) && ~isinf( deltat ) )
                %obj.deltat = deltat;
            else
                ex = MException( "CellModel:deltat", ...
                                 "Expected to be a time duration (real/duration).");
                throw(ex);
            end
            
            % Check Coefficients...
            fldexist = @(field) isfield( coeffs, field );
            tfa = cellfun( fldexist, obj.coeffNames );
            
            if( ~all(tfa) )
                ex = MException( "CellModel:coeffs", ...
                                 "Required coefficients '%s' not FOUND!", ...
                                 strjoin( [obj.coeffNames{~tfa}], " ," ) );
                throw(ex);
            end
            
            % Check covariances
            fldexist = @(field) isfield( cov, field );
            tfa = cellfun( fldexist, obj.Covariances );
            
            if( ~all(tfa) )
                ex = MException( "CellModel:cov", ...
                                 "Required Covariances '%s' not FOUND!", ...
                                 strjoin( [obj.Covariances{~tfa}], " ," ) );
                throw(ex);
            end

            %Check cell model consistency!
            if obj.Nx ~= length( obj.xNames )
                ex = MException( "CellModel:xNames", ...
                                 "Wrong class implementaion." );
                throw(ex);
            end
            
            if obj.Np ~= length( obj.pNames )
                ex = MException( "CellModel:pNames", ...
                                 "Wrong class implementaion." );
                throw(ex);
            end
            
            if obj.Nu ~= length( obj.uNames )
                ex = MException( "CellModel:uNames", ...
                                 "Wrong class implementaion." );
                throw(ex);
            end
            
            if obj.Ny ~= length( obj.yNames )
                ex = MException( "CellModel:yNames", ...
                                 "Wrong class implementaion." );
                throw(ex);
            end
        end
        
        function tf = checkCoefficients( obj, coeffs )
            
            fldexist = @(field) isfield( coeffs, field );
            tfa = cellfun( fldexist, obj.coeffNames );
            
            if( ~all(tfa) )
                dispError( "Required coefficients '%s' not FOUND!\n", strjoin( [obj.coeffNames{~tfa}], " ," ) );
                tf = false;
            else
                tf = true;
            end
        end
        
        function ret = checkCovariances( obj, cov )
            
            fldexist = @(field) isfield( cov, field );
            tfa = cellfun( fldexist, obj.Covariances );
            
            if( ~all(tfa) )
                dispError( "Required Covariances '%s' not FOUND!", strjoin( [obj.Covariances{~tfa}], " ," ) );
                ret = false;
            else
                ret = true;
            end
        end

    end
    
    methods(Abstract)
        
        % state update (f) -> {Nx,1}
        res = f0( obj, xold, pold, uold, deltat );

        % output update (g) -> {Ny,1}
        res = g0( obj, xold, pold, uold, deltat );

        % derivative of f respect to x -> {Nx, Nx} 
        res = f1x( obj, xold, pold, uold, deltat );

        % derivative of f respect to p -> {Nx, Np}
        res = f1p( obj, xold, pold, uold, deltat );

        % derivative of g respect to x -> {Ny, Nx}
        res = g1x( obj, xold, pold, uold, deltat );

        % derivative of g respect to p -> {Ny, Np}
        res = g1p( obj, xold, pold, uold, deltat );
        
    end
    
end

