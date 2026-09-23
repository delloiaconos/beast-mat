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
    %CELLMODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Abstract)
        Nx;
        Np;
        Nu;
        Ny;
        
        Required;
        Xnames;
        Pnames;
        Unames;
        Ynames;
    end
    
    properties( Constant )
        zerohere = 1.e-9;
    end
    
    methods
        
        function obj = CellModel( obj )
            
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
        
        function tf = checkContructor( obj, CellModelData, COV )
            
            CovarianceNames = { 'sxW', 'sxV', 'spE', 'spR' }; 
            
            tf = true;
            
            fldexist = @(x) beast.CellModels.CellModel.strctfieldexists( CellModelData, x );
            tfa = cellfun( fldexist, obj.Required );
            
            if( find( tfa == false, 1, 'first' ) )
                disp( 'ERROR: Required CellModelData not FOUND!' );
                tf = false;
            else
                tf = true;
            end
            
            fldexist = @(x) beast.CellModels.CellModel.strctfieldexists( COV, x );
            tfa = cellfun( fldexist, CovarianceNames );
            
            if( find( tfa == false, 1, 'first' ) )
                disp( 'ERROR: Required Covariances not FOUND!' );
                tf = false;
            else
                tf = tf & true;
            end
        end
        
        function tf = checkCoefficients( obj, CellModelData )
            
            fldexist = @(x) beast.CellModels.CellModel.strctfieldexists( CellModelData, x );
            tfa = cellfun( fldexist, obj.Required );
            
            if( find( tfa == false, 1, 'first' ) )
                disp( 'ERROR: Required CellModelData not FOUND!' );
                tf = false;
            else
                tf = true;
            end
        end
        
        function ret = checkCovariances( obj, COV )
          
            ret = true;
            fldexist = @(x) beast.CellModels.CellModel.strctfieldexists( COV, x );
            
            if( fldexist( 'sxV' ) == true )
                if( size( COV.sxV ) == [obj.Nu obj.Nu] )
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
                if( size( COV.spE ) == [obj.Ny obj.Ny] )
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
                if( size( COV.sxW ) == [obj.Nx obj.Nx] )
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
                if( size( COV.spR ) == [obj.Np obj.Np] )
                    ret = ret & true;
                else
                    disp( 'ERROR: Wrong size for Covariances spR!' );
                    ret = false;
                end
            else
                disp( 'ERROR: Covariances spR not FOUND!' );
                ret = false;
            end
            
        end % function ret = checkCovariances( obj, COV )
        
    end % methods
    
    methods( Access = private, Static )
        
        function fexists = strctfieldexists(thestruct, thefield)
            if isstr(thestruct)
                todo = sprintf('getfield(%s,''%s'');', thestruct, thefield);
                fexists = 1; evalin('caller', todo, 'fexists=0;');
            else
                fexists = any( strcmp(fieldnames(thestruct), thefield) );
                fexists = 1; eval('getfield(thestruct, thefield);', 'fexists=0;'); 
            end;
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

