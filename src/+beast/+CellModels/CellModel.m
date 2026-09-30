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
    
    properties(Constant)
        zerohere = 1.e-9;
    end

    properties(Constant,GetAccess=public)
        Covariances = { "sxW", "sxV", "spE", "spR" }; 
    end

    properties(Constant,GetAccess=public,Abstract)
        Nx;
        Np;
        Nu;
        Ny;
        
        Coefficients;
        States;
        Parameters;
        Inputs;
        Outputs;
    end

    properties(SetAccess=immutable,GetAccess=public)
        deltatfix
    end

    properties(SetAccess=protected,GetAccess=public)
        sxW;
        sxV;
        spR;
        spE;
    end

    methods(Access=private)
        function obj = checkStandardObjType( obj, myName, myObj )

            % Every concrete cell model must provide a non-empty ordered
            % struct array with Name and Bounds fields.
            if ~isstruct(myObj) || isempty(myObj) || ~isvector(myObj) || ...
                    ~all(isfield(myObj, {'Name', 'Bounds'}))
                ex = MException( "CellModel:checkStandardObjType", ...
                    sprintf( "Variable '%s' must be a non-empty ordered struct array with Name and Bounds fields.", myName ) );
                throw(ex);
            end

            objValues = {myObj.Bounds};
            containsBounds = all(cellfun( ...
                @(value) isa(value, 'Bounds') && isscalar(value), ...
                objValues));

            objNames = {myObj.Name};
            containsNames = all(cellfun( ...
                @(name) (ischar(name) || isstring(name)) && isscalar(string(name)), ...
                objNames));
            if containsNames
                names = string(objNames);
                containsNames = all(strlength(names) > 0) && ...
                    numel(unique(names)) == numel(names);
            end

            if ~containsBounds || ~containsNames
                ex = MException( "CellModel:checkStandardObjType", ...
                    sprintf( "Every '%s' entry must have a unique name and a scalar Bounds object.", myName ) );
                throw(ex);
            end

        end
    end
    
    methods(Access=protected)

        function obj = CellModel( coeffs, cov, deltat )
            % Check CellModel Class specifications for Abstract properties.

            % Check `Coefficients` property.
            obj.checkStandardObjType( "Coefficients", obj.Coefficients );

            % Check constructur specifications
            if isa( deltat, 'duration' )
                deltat = seconds( deltat );
            end

            if( isreal( deltat ) && ~isnan( deltat ) && ...
                ( deltat > 0 ) && ~isinf( deltat ) )
                obj.deltatfix = deltat;
            else
                ex = MException( "CellModel:deltat", ...
                                 "Expected to be a time duration (real/duration).");
                throw(ex);
            end
            
            if( ~obj.checkCoefficients( coeffs ) )
                ex = MException( "CellModel:coeffs", ...
                                 "Required coefficients not FOUND!"  );
                throw(ex);
            end
            
            % Check Covariances
            fldexist = @(field) isfield( cov, field );
            tfa = cellfun( fldexist, obj.Covariances );
            
            if( ~all(tfa) )
                ex = MException( "CellModel:cov", ...
                                 "Required Covariances '%s' not FOUND!", ...
                                 strjoin( [obj.Covariances{~tfa}], " ," ) );
                throw(ex);
            end

            %Check cell model consistency!
            if obj.Nx ~= length( obj.States )
                ex = MException( "CellModel:States", ...
                                 "Wrong class implementaion." );
                throw(ex);
            end
            
            if obj.Np ~= length( obj.Parameters )
                ex = MException( "CellModel:Parameters", ...
                                 "Wrong class implementaion." );
                throw(ex);
            end
            
            if obj.Nu ~= length( obj.Inputs )
                ex = MException( "CellModel:Inputs", ...
                                 "Wrong class implementaion." );
                throw(ex);
            end
            
            if obj.Ny ~= length( obj.Outputs )
                ex = MException( "CellModel:Outputs", ...
                                 "Wrong class implementaion." );
                throw(ex);
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
    
    methods(Access=public,Abstract)
        
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
    
    methods(Access=public)

        function tf = checkCoefficients( obj, coeffs )
            % Check supplied coefficient exists.
            k = string({obj.Coefficients.Name});

            fldexist = @(field) isfield( coeffs, char(field) );
            tf = all( arrayfun( fldexist, k ) );
        end

        function valid = validateCoefficients( obj, coeffs ) 
            % Check supplied coefficient boundaries.
            k = string({obj.Coefficients.Name});
            tf = false(size(k));

            for ii = 1:numel(k)
                field = char(k(ii));
                if isfield(coeffs, field)
                    tf(ii) = obj.Coefficients(ii).Bounds.validate(coeffs.(field));
                end
            end

            valid = all( tf );
        end
        
    end
end

