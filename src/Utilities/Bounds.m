classdef Bounds
    %BOUNDS Scalar interval validator.
    %   BOUNDS(LB, UB, STRICTLB, STRICTUB) describes the interval between
    %   scalar numeric bounds LB and UB.  A NaN or complex bound is
    %   treated as absent.  STRICTLB and STRICTUB select open boundaries;
    %   otherwise the corresponding boundary is closed.
    %
    %   VALIDATE(OBJ, VALUE) returns true when VALUE is a real, non-NaN
    %   scalar numeric value inside the interval, and false otherwise.

    properties(Access=protected)
        lb (1,1) double = -Inf
        ub (1,1) double = Inf
        strictLB (1,1) logical = false  % false = >= , true = >
        strictUB (1,1) logical = false  % false = <= , true = <
    end
    
    methods(Access=public)
        function obj = Bounds(lb, ub, strictLB, strictUB)
            if nargin > 4
                error('Bounds:arguments', ...
                    'Bounds accepts at most four input arguments.');
            end

            if nargin > 0
                if ~isnumeric(lb) || ~isscalar(lb)
                    error('Bounds:lb', ...
                        'Lower bound must be a scalar numeric value.');
                end
                obj.lb = double(lb);
            end

            if nargin > 1
                if ~isnumeric(ub) || ~isscalar(ub)
                    error('Bounds:ub', ...
                        'Upper bound must be a scalar numeric value.');
                end
                obj.ub = double(ub);
            end

            if nargin > 2
                if ~islogical(strictLB) || ~isscalar(strictLB)
                    error('Bounds:strictLB', ...
                        'strictLB must be a scalar logical value.');
                end
                obj.strictLB = strictLB;
            end
            
            if nargin > 3
                if ~islogical(strictUB) || ~isscalar(strictUB)
                    error('Bounds:strictUB', ...
                        'strictUB must be a scalar logical value.');
                end
                obj.strictUB = strictUB;
            end
        end
        
        function valid = validate(obj, val)
            
            if isvector( val ) && ~isscalar( val )
                tf = arrayfun( @(v) obj.validate( v ), val );
                valid = all( tf );
                return
            end

            % Check Value
            if ~isnumeric(val) || ~isscalar(val) || ...
                ~isreal( val ) || isnan( val )
                valid = false;
                return;
            end

            % Check Lower Bound
            if isreal( obj.lb ) && ~isnan( obj.lb ) 
                if obj.strictLB
                    validLB = (val > obj.lb);
                else
                    validLB = (val >= obj.lb);
                end
            else
                validLB = true;
            end
            
            % Check Upper Bound
            if isreal( obj.ub ) && ~isnan( obj.ub ) 
                if obj.strictUB
                    validUB = (val < obj.ub);
                else
                    validUB = (val <= obj.ub);
                end
            else
                validUB = true;
            end

            valid = validLB && validUB;
        end
    end
end
