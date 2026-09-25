classdef Bounds
    %BOUNDS Scalar interval validator.
    %   BOUNDS(LB, UB, STRICTLB, STRICTUB) describes the interval between
    %   the scalar double bounds LB and UB.  A NaN or complex bound is
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
            if nargin > 0, obj.lb = lb; end
            if nargin > 1, obj.ub = ub; end
            if nargin > 2, obj.strictLB = strictLB; end
            if nargin > 3, obj.strictUB = strictUB; end
        end
        
        function valid = validate(obj, val)
            
            % Check Value
            if ~isnumeric(val) || ~isscalar(val) || ...
                ~isreal( val ) || isnan( val )
                valid = false;
                return;
            end

            % Check Lower Bound
            if ~isnan( obj.lb ) && isreal( obj.lb )
                if obj.strictLB
                    validLB = (val > obj.lb);
                else
                    validLB = (val >= obj.lb);
                end
            else
                validLB = true;
            end
            
            % Check Upper Bound
            if ~isnan( obj.ub ) && isreal( obj.ub )
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
