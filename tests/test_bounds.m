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

function results = test_bounds(results)
    % Exercise every combination of lower bound, upper bound, and value.
    % The heterogeneous inputs intentionally include values which are not
    % accepted by the Bounds scalar-numeric interface.
    inputs = { ...
        0.0, ...
        1.0 + 2.0i, ...
        NaN, ...
        "", ...
        "STRING", ...
        'string', ...
        Inf, ...
        true, ...
        int32(1), ...
        [], ...
        [0.0, 1.0], ...
        struct('value', 1) ...
    };

    for iLB = 1:numel(inputs)
        for iUB = 1:numel(inputs)
            lb = inputs{iLB};
            ub = inputs{iUB};

            % Bounds accepts scalar numeric bounds, but not logical, text,
            % empty, vector, or struct inputs.
            boundsAccepted = isnumeric(lb) && isscalar(lb) && ...
                isnumeric(ub) && isscalar(ub);

            for iValue = 1:numel(inputs)
                value = inputs{iValue};
                testName = sprintf( ...
                    'Bounds(lb=%d,ub=%d,value=%d)', iLB, iUB, iValue);

                if ~boundsAccepted
                    try
                        Bounds(lb, ub, false, false);
                        results(end+1) = recordTestResult( ...
                            testName, 'FAILED', ...
                            sprintf(['Expected constructor rejection for lower ' ...
                            'bound class %s and upper bound class %s.'], ...
                            class(lb), class(ub)));
                    catch ex
                        % Expected: the constructor rejects invalid bounds.
                        results(end+1) = recordTestResult( ...
                            testName, 'PASSED', ...
                            sprintf(['Rejected invalid bounds (lb class %s, ub class %s): ' ...
                            '%s'], class(lb), class(ub), ex.message));
                    end
                    continue;
                end

                % Test all four open/closed-boundary combinations.
                for strictLB = [false, true]
                    for strictUB = [false, true]
                        strictName = sprintf('%s,strictLB=%d,strictUB=%d', ...
                            testName, strictLB, strictUB);
                        try
                            obj = Bounds(lb, ub, strictLB, strictUB);
                            actual = obj.validate(value);
                            expected = expectedValidation(lb, ub, value, ...
                                strictLB, strictUB);

                            if ~isequal(actual, expected)
                                error('BoundsTest:unexpectedResult', ...
                                    'Expected %d, received %d.', expected, actual);
                            end

                            results(end+1) = recordTestResult( ...
                                strictName, 'PASSED', ...
                                sprintf(['Validated lb=%s, ub=%s, value=%s.'], ...
                                class(lb), class(ub), class(value)));
                        catch ex
                            results(end+1) = recordTestResult( ...
                                strictName, 'FAILED', ...
                                sprintf(['lb=%s, ub=%s, value=%s: %s'], ...
                                class(lb), class(ub), class(value), ex.message));
                        end
                    end
                end
            end
        end
    end

    % Verify that strict-bound arguments accept logical values only.
    strictInputs = {0, 1, "", "STRING", 'string', int32(1), [], [true, false]};
    for iStrict = 1:numel(strictInputs)
        strictValue = strictInputs{iStrict};
        testName = sprintf('Bounds(strict=%d)', iStrict);

        try
            Bounds(0, 1, strictValue, false);
            results(end+1) = recordTestResult( ...
                testName, 'FAILED', ...
                sprintf('Accepted invalid strictLB class %s.', class(strictValue)));
        catch ex
            results(end+1) = recordTestResult( ...
                testName, 'PASSED', ...
                sprintf('Rejected invalid strictLB class %s: %s', ...
                class(strictValue), ex.message));
        end

        try
            Bounds(0, 1, false, strictValue);
            results(end+1) = recordTestResult( ...
                testName, 'FAILED', ...
                sprintf('Accepted invalid strictUB class %s.', class(strictValue)));
        catch ex
            results(end+1) = recordTestResult( ...
                testName, 'PASSED', ...
                sprintf('Rejected invalid strictUB class %s: %s', ...
                class(strictValue), ex.message));
        end
    end
end

function expected = expectedValidation(lb, ub, value, strictLB, strictUB)
    if isnumeric(value) && isvector(value) && ~isscalar(value)
        expected = all(arrayfun( ...
            @(element) expectedValidation(lb, ub, element, strictLB, strictUB), ...
            value));
        return;
    end

    if ~isnumeric(value) || ~isscalar(value) || ~isreal(value) || isnan(value)
        expected = false;
        return;
    end

    value = double(value);

    if isnan(lb) || ~isreal(lb)
        validLB = true;
    elseif strictLB
        validLB = value > lb;
    else
        validLB = value >= lb;
    end

    if isnan(ub) || ~isreal(ub)
        validUB = true;
    elseif strictUB
        validUB = value < ub;
    else
        validUB = value <= ub;
    end

    expected = validLB && validUB;
end
