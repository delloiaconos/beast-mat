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
        
        coefficients;
        states;
        parameters;
        Inputs;
        Outputs;
    end

    properties(Constant,GetAccess=protected,Abstract)
        coefficientsBound;
        statesBound;
        parametersBound;
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

            if any(strcmp(myName, ["coefficients", "states", "parameters"]))
                if iscell(myObj)
                    names = string(myObj);
                    isValid = all(cellfun( ...
                        @(name) (ischar(name) && isrow(name)) || ...
                        (isstring(name) && isscalar(name)), myObj));
                elseif isstring(myObj)
                    names = myObj;
                    isValid = all(isscalar(myObj) | isstring(myObj));
                else
                    names = strings(0, 1);
                    isValid = false;
                end

                isValid = isValid && ~isempty(names) && isvector(names) && ...
                    all(strlength(names) > 0) && ...
                    numel(unique(names)) == numel(names);
            else
                isValid = iscell(myObj) && ~isempty(myObj) && ...
                    all(cellfun(@(value) isa(value, 'Bounds') && isscalar(value), myObj));
            end

            if ~isValid
                ex = MException( "CellModel:checkStandardObjType", ...
                    sprintf( "Variable '%s' has an invalid type or contents.", myName ) );
                throw(ex);
            end

        end
    end
    
    methods(Access=protected)

        function obj = CellModel( coeffs, cov, deltat )
            % Check CellModel Class specifications for Abstract properties.

            % Check coefficient names, bounds, and their ordering.
            obj.checkStandardObjType( "coefficients", obj.coefficients );
            obj.checkStandardObjType( "coefficientsBound", obj.coefficientsBound );
            if numel(obj.coefficients) ~= numel(obj.coefficientsBound)
                ex = MException( "CellModel:coefficients", ...
                    "coefficients and coefficientsBound must have the same length." );
                throw(ex);
            end

            obj.checkStandardObjType( "states", obj.states );
            obj.checkStandardObjType( "statesBound", obj.statesBound );
            if numel(obj.states) ~= numel(obj.statesBound)
                ex = MException( "CellModel:states", ...
                    "states and statesBound must have the same length." );
                throw(ex);
            end

            obj.checkStandardObjType( "parameters", obj.parameters );
            obj.checkStandardObjType( "parametersBound", obj.parametersBound );
            if numel(obj.parameters) ~= numel(obj.parametersBound)
                ex = MException( "CellModel:parameters", ...
                    "parameters and parametersBound must have the same length." );
                throw(ex);
            end

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
            if obj.Nx ~= length( obj.states )
                ex = MException( "CellModel:States", ...
                                 "Wrong class implementaion." );
                throw(ex);
            end
            
            if obj.Np ~= length( obj.parameters )
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
            k = string(obj.coefficients);

            fldexist = @(field) isfield( coeffs, char(field) );
            tf = all( arrayfun( fldexist, k ) );
        end

        function valid = validateCoefficients( obj, coeffs ) 
            % Check supplied coefficient boundaries.
            k = string(obj.coefficients);
            tf = false(size(k));

            for ii = 1:numel(k)
                field = char(k(ii));
                if isfield(coeffs, field)
                    tf(ii) = obj.coefficientsBound{ii}.validate(coeffs.(field));
                end
            end

            valid = all( tf );
        end

        function valid = validateParameter( obj, p )
            % Validate each parameter against its corresponding bound.
            if ~isnumeric(p) || numel(p) ~= obj.Np
                valid = false;
                return;
            end

            values = p(:);
            valid = true;
            for ii = 1:obj.Np
                valid = valid && obj.parametersBound{ii}.validate(values(ii));
            end
        end

        function valid = validateStates( obj, x )
            % Validate each state against its corresponding bound.
            if ~isnumeric(x) || numel(x) ~= obj.Nx
                valid = false;
                return;
            end

            values = x(:);
            valid = true;
            for ii = 1:obj.Nx
                valid = valid && obj.statesBound{ii}.validate(values(ii));
            end
        end

        function p = coerceParameters( obj, p )
            % Coerce each parameter using its corresponding bound.
            if ~isnumeric(p) || numel(p) ~= obj.Np
                p = NaN;
                return;
            end

            originalSize = size(p);
            values = p(:);
            for ii = 1:obj.Np
                values(ii) = obj.parametersBound{ii}.coerce(values(ii));
            end
            p = reshape(values, originalSize);
        end

        function x = coerceStates( obj, x )
            % Coerce each state using its corresponding bound.
            if ~isnumeric(x) || numel(x) ~= obj.Nx
                x = NaN;
                return;
            end

            originalSize = size(x);
            values = x(:);
            for ii = 1:obj.Nx
                values(ii) = obj.statesBound{ii}.coerce(values(ii));
            end
            x = reshape(values, originalSize);
        end
        
    end
end

