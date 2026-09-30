classdef Bounds
    %BOUNDS Scalar real bounds with recursive validation and coercion.
    %   BOUNDS(LB, UB, STRICTLB, STRICTUB) defines lower and upper bounds.
    %   Bounds must be scalar real numeric values. NaN and +/-Inf disable
    %   the corresponding bound. STRICTLB and STRICTUB select open bounds.
    %
    %   VALIDATE(OBJ, VALUE) returns a scalar logical. Numeric arrays are
    %   validated element by element; invalid or nonnumeric inputs return
    %   false without throwing an error.
    %
    %   COERCE(OBJ, VALUE) moves numeric values into the bounds recursively
    %   and preserves the input numeric class. Invalid inputs return NaN.

    properties(Access=private)
        epsilon (1,1) double = 1e-15
        lb (1,1) double = -Inf
        ub (1,1) double = Inf
        strictLB (1,1) logical = false
        strictUB (1,1) logical = false
    end

    methods(Access=public)
        function obj = Bounds(lb, ub, strictLB, strictUB)
            if nargin > 4
                error('Bounds:arguments', ...
                    'Bounds accepts at most four input arguments.');
            end

            if nargin > 0
                validateBound(lb, 'lower');
                obj.lb = double(lb);
            end

            if nargin > 1
                validateBound(ub, 'upper');
                obj.ub = double(ub);
            end

            if nargin > 2
                validateStrict(strictLB, 'strictLB');
                obj.strictLB = strictLB;
            end

            if nargin > 3
                validateStrict(strictUB, 'strictUB');
                obj.strictUB = strictUB;
            end
        end

        function valid = validate(obj, val)
            % Validation is deliberately non-throwing for arbitrary input.
            try
                if ~isnumeric(val) || isempty(val) || ~isreal(val)
                    valid = false;
                    return;
                end

                if ~isscalar(val)
                    elementResults = arrayfun( ...
                        @(element) obj.validate(element), val);
                    valid = all(elementResults(:));
                    return;
                end

                value = double(val);
                validLB = true;
                validUB = true;

                if ~isnan(obj.lb) && ~isinf(obj.lb)
                    if obj.strictLB
                        validLB = value > obj.lb;
                    else
                        validLB = value >= obj.lb;
                    end
                end

                if ~isnan(obj.ub) && ~isinf(obj.ub)
                    if obj.strictUB
                        validUB = value < obj.ub;
                    else
                        validUB = value <= obj.ub;
                    end
                end

                valid = logical(validLB && validUB);
            catch
                valid = false;
            end
        end

        function coerced = coerce(obj, val)
            % Coercion returns NaN for invalid or nonnumeric inputs.
            try
                if ~isnumeric(val) || isempty(val) || ~isreal(val)
                    coerced = NaN;
                    return;
                end

                if ~isscalar(val)
                    coerced = arrayfun(@(element) obj.coerce(element), val);
                    coerced = cast(coerced, 'like', val);
                    return;
                end

                value = double(val);

                if ~isnan(obj.lb) && ~isinf(obj.lb)
                    if obj.strictLB
                        if value <= obj.lb
                            value = obj.lb + obj.epsilon;
                        end
                    elseif value < obj.lb
                        value = obj.lb;
                    end
                end

                if ~isnan(obj.ub) && ~isinf(obj.ub)
                    if obj.strictUB
                        if value >= obj.ub
                            value = obj.ub - obj.epsilon;
                        end
                    elseif value > obj.ub
                        value = obj.ub;
                    end
                end

                coerced = cast(value, 'like', val);
            catch
                coerced = NaN;
            end
        end
    end
end

function validateBound(value, boundName)
    if ~isnumeric(value) || ~isscalar(value) || ~isreal(value)
        error(['Bounds:' boundName], ...
            '%s bound must be a scalar real numeric value.', boundName);
    end
end

function validateStrict(value, argumentName)
    if ~islogical(value) || ~isscalar(value)
        error(['Bounds:' argumentName], ...
            '%s must be a scalar logical value.', argumentName);
    end
end
