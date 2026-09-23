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
    
    methods(Access = public)
        
        function obj = CellModel( )
            
            %Check cell model consistency!
            if obj.Nx ~= length( obj.Xnames )
                disp( 'ERROR: X names error!' );
            end
            
            if obj.Np ~= length( obj.Pnames )
                disp( 'ERROR: P names error!' );
            end
            
            if obj.Nu ~= length( obj.Unames )
                disp( 'ERROR: U names error!' );
            end
            
            if obj.Ny ~= length( obj.Ynames )
                disp( 'ERROR: Y names error!' );
            end
        end
        
        function tf = checkContructor( obj, coefficients, cov )
            
            CovarianceNames = { 'sxW', 'sxV', 'spE', 'spR' }; 
            
            fldexist = @(field) isfield( coefficients, field );
            tfa = cellfun( fldexist, obj.Coefficients );
            
            if( find( tfa == false, 1, 'first' ) )
                disp( 'ERROR: Required coefficients not FOUND!' );
                tf = false;
            else
                tf = true;
            end
            
            fldexist = @(field) isfield( cov, x );
            tfa = cellfun( fldexist, CovarianceNames );
            
            if( find( tfa == false, 1, 'first' ) )
                disp( 'ERROR: Required Covariances not FOUND!' );
                tf = false;
            else
                tf = tf & true;
            end
        end
        
        function tf = checkCoefficients( obj, coefficients )
            
            fldexist = @(field) isfield( coefficients, field );
            tfa = cellfun( fldexist, obj.Coefficients );
            
            if( find( tfa == false, 1, 'first' ) )
                disp( 'ERROR: Required coefficients not FOUND!' );
                tf = false;
            else
                tf = true;
            end
        end
        
        function ret = checkCovariances( obj, cov )
          
            ret = true;
            fldexist = @(field) isfield( cov, field );
            
            if( fldexist( 'sxV' ) == true )
                if( size( cov.sxV ) == [obj.Nu obj.Nu] )
                    ret = ret & true;
                else
                    disp( 'ERROR: Wrong size for Covariances sxV!' );
                    ret = false;
                end
            else
                disp( 'ERROR: Covariances sxV not FOUND!' );
                ret = false;
            end
            
            if( fldexist( 'spE' ) == true )
                if( size( cov.spE ) == [obj.Ny obj.Ny] )
                    ret = ret & true;
                else
                    disp( 'ERROR: Wrong size for Covariances spE!' );
                    ret = false;
                end
            else
                disp( 'ERROR: Covariances spE not FOUND!' );
                ret = false;
            end
            
            if( fldexist( 'sxW' ) == true )
                if( size( cov.sxW ) == [obj.Nx obj.Nx] )
                    ret = ret & true;
                else
                    disp( 'ERROR: Wrong size for Covariances sxW!' );
                    ret = false;
                end
            else
                disp( 'ERROR: Covariances sxW not FOUND!' );
                ret = false;
            end
            
            if( fldexist( 'spR' ) == true )
                if( size( cov.spR ) == [obj.Np obj.Np] )
                    ret = ret & true;
                else
                    disp( 'ERROR: Wrong size for Covariances spR!' );
                    ret = false;
                end
            else
                disp( 'ERROR: Covariances spR not FOUND!' );
                ret = false;
            end
        
        end
    end
    
    methods( Abstract )
        
        % state update (f)
        res = f0( obj, xold, pold, uold, deltat );

        % output update (g) 
        res = g0( obj, xold, pold, uold, deltat );

        % derivative of f respect to x
        res = f1x( obj, xold, pold, uold, deltat );

        % derivative of f respect to p
        res = f1p( obj, xold, pold, uold, deltat );

        % derivative of g respect to x
        res = g1x( obj, xold, pold, uold, deltat );

        % derivative of g respect to p 
        res = g1p( obj, xold, pold, uold, deltat );
        
    end
    
end

