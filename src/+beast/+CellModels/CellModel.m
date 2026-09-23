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
    
    properties(Constant, Abstract)
        Nx;
        Np;
        Nu;
        Ny;
        
        Coefficients;

        Xnames;
        Pnames;
        Unames;
        Ynames;
    end
    
    properties(Constant)
        zerohere = 1.e-9;
    end
    
    methods(Access=protected)
        
        function obj = CellModel( )
            
            %Check cell model consistency!
            if obj.Nx ~= length( obj.Xnames )
                dispError( 'X names error!' );
            end
            
            if obj.Np ~= length( obj.Pnames )
                dispError( 'P names error!' );
            end
            
            if obj.Nu ~= length( obj.Unames )
                dispError( 'U names error!' );
            end
            
            if obj.Ny ~= length( obj.Ynames )
                dispError( 'Y names error!' );
            end
        end
        
        function tf = checkContructor( obj, coeffs, cov, deltat )
            
            CovarianceNames = { 'sxW', 'sxV', 'spE', 'spR' }; 

            if( deltat <= 0 )
                dispError( 'deltat must be > 0.0!' );
            end

            fldexist = @(field) isfield( coeffs, field );
            tfa = cellfun( fldexist, obj.Coefficients );
            
            if( ~all(tfa) )
                dispError( "Required coefficients '%s' not FOUND!", strjoin( [obj.Coefficients{~tfa}], " ," ) );
                tf = false;
            else
                tf = true;
            end
            
            fldexist = @(field) isfield( cov, field );
            tfa = cellfun( fldexist, CovarianceNames );
            
            if( ~all(tfa) )
                dispError( "Required Covariances '%s' not FOUND!", strjoin( [CovarianceNames{~tfa}], " ," ) );
                tf = false;
            else
                tf = tf & true;
            end
        end
        
        function tf = checkCoefficients( obj, coeffs )
            
            fldexist = @(field) isfield( coeffs, field );
            tfa = cellfun( fldexist, obj.Coefficients );
            
            if( ~all(tfa) )
                dispError( "Required coefficients '%s' not FOUND!\n", strjoin( [obj.Coefficients{~tfa}], " ," ) );
                tf = false;
            else
                tf = true;
            end
        end
        
        function ret = checkCovariances( obj, cov )
          
            ret = true;
            fldexist = @(field) isfield( cov, field );
            
            if( fldexist( 'sxV' ) == true )
                if( isequal( size( cov.sxV ), [obj.Nu obj.Nu] ) )
                    ret = ret & true;
                else
                    dispError( 'Wrong size for Covariances sxV!' );
                    ret = false;
                end
            else
                dispError( 'Covariances sxV not FOUND!' );
                ret = false;
            end
            
            if( fldexist( 'spE' ) == true )
                if( isequal( size( cov.spE ), [obj.Ny obj.Ny] ) )
                    ret = ret & true;
                else
                    dispError( 'Wrong size for Covariances spE!' );
                    ret = false;
                end
            else
                dispError( 'Covariances spE not FOUND!' );
                ret = false;
            end
            
            if( fldexist( 'sxW' ) == true )
                if( isequal( size( cov.sxW ), [obj.Nx obj.Nx] ) )
                    ret = ret & true;
                else
                    dispError( 'Wrong size for Covariances sxW!' );
                    ret = false;
                end
            else
                dispError( 'Covariances sxW not FOUND!' );
                ret = false;
            end
            
            if( fldexist( 'spR' ) == true )
                if( isequal( size( cov.spR ), [obj.Np obj.Np] ) )
                    ret = ret & true;
                else
                    dispError( 'Wrong size for Covariances spR!' );
                    ret = false;
                end
            else
                dispError( 'Covariances spR not FOUND!' );
                ret = false;
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

