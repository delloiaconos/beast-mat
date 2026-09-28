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
    % accepted by the Bounds scalar-double interface.
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

            % Bounds' typed scalar properties reject non-double bounds.
            boundsAccepted = isa(lb, 'double') && isscalar(lb) && ...
                isa(ub, 'double') && isscalar(ub);

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
                        % Expected: the scalar-double property validator rejects it.
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
end

function expected = expectedValidation(lb, ub, value, strictLB, strictUB)
    if ~isnumeric(value) || ~isscalar(value) || ~isreal(value) || isnan(value)
        expected = false;
        return;
    end

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
