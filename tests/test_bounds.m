% BEAST - Battery Estimation Algorithms and Simulation Toolkit
%
% This file is part of the BEAST MATLAB implementation.
%
% Project:
%   Battery Estimation Algorithms and Simulation Toolkit (BEAST)
%
% Repository:
%   https://github.com/delloiaconos/beast-mat

function results = test_bounds(results)
    % Each row contains:
    %   {name, constructor arguments, value, expected result, error expected}
    % The case definitions are created before any Bounds object is created.
    validateCases = { ...
        'closed lower boundary',       {0, 1, false, false},       0,          true,  false; ...
        'strict lower boundary',       {0, 1, true,  false},       0,          false, false; ...
        'closed upper boundary',       {0, 1, false, false},       1,          true,  false; ...
        'strict upper boundary',       {0, 1, false, true},        1,          false, false; ...
        'NaN lower bound disabled',    {NaN, 10, false, false},     5,          true,  false; ...
        'infinite bounds disabled',    {-Inf, Inf, false, false},  Inf,        true,  false; ...
        'complex value rejected',      {0, 1, false, false},       1+2i,       false, false; ...
        'NaN value rejected',          {0, 1, false, false},       NaN,        false, false; ...
        'integer value accepted',      {0, 2, false, false},       int32(1),   true,  false; ...
        'vector all valid',            {0, 1, false, false},       [0, 1],     true,  false; ...
        'vector one invalid',          {0, 1, false, false},       [-1, 1],    false, false; ...
        'matrix all valid',            {0, 1, false, false},       [0, 1; 1, 0], true, false; ...
        'matrix one invalid',          {0, 1, false, false},       [0, 1; 2, 0], false, false; ...
        'string value rejected',       {0, 1, false, false},       "STRING",   false, false ...
    };

    coerceCases = { ...
        'coerce lower closed',         {0, 1, false, false},       -1,         0,             false; ...
        'coerce lower strict',         {0, 1, true,  false},       -1,         1e-15,         false; ...
        'coerce upper closed',         {0, 1, false, false},       2,          1,             false; ...
        'coerce upper strict',         {0, 1, false, true},        2,          1-1e-15,       false; ...
        'coerce preserves integer',    {0, 1, false, false},       int32(-1),  int32(0),       false; ...
        'coerce matrix',               {0, 1, false, false},       [-1, 0; 1, 2], [0, 0; 1, 1], false; ...
        'coerce string returns NaN',   {0, 1, false, false},       "STRING",   NaN,           false; ...
        'coerce complex returns NaN',  {0, 1, false, false},       1+2i,        NaN,           false ...
    };

    constructCases = { ...
        'complex lower bound rejected', {1+2i, 1, false, false}, [], [], true; ...
        'vector lower bound rejected',  {[0, 1], 1, false, false}, [], [], true; ...
        'numeric strict flag rejected', {0, 1, 1, false},          [], [], true ...
    };

    for testIndex = 1:size(validateCases, 1)
        results(end+1) = runValidateCase(validateCases{testIndex, :});
    end

    for testIndex = 1:size(coerceCases, 1)
        results(end+1) = runCoerceCase(coerceCases{testIndex, :});
    end

    for testIndex = 1:size(constructCases, 1)
        results(end+1) = runConstructCase(constructCases{testIndex, :});
    end
end

function result = runValidateCase(name, constructorArguments, value, expected, errorExpected)
    try
        obj = Bounds(constructorArguments{:});
        actual = obj.validate(value);
        result = compareBoundsResult(name, actual, expected, errorExpected, 'validate');
    catch ex
        result = handleBoundsError(name, ex, errorExpected);
    end
end

function result = runCoerceCase(name, constructorArguments, value, expected, errorExpected)
    try
        obj = Bounds(constructorArguments{:});
        actual = obj.coerce(value);
        result = compareBoundsResult(name, actual, expected, errorExpected, 'coerce');
    catch ex
        result = handleBoundsError(name, ex, errorExpected);
    end
end

function result = runConstructCase(name, constructorArguments, value, expected, errorExpected)
    try
        Bounds(constructorArguments{:});
        actual = value;
        result = compareBoundsResult(name, actual, expected, errorExpected, 'construct');
    catch ex
        result = handleBoundsError(name, ex, errorExpected);
    end
end

function result = compareBoundsResult(name, actual, expected, errorExpected, operation)
    if errorExpected
        result = recordTestResult(name, 'FAILED', ...
            'Expected the constructor to reject the supplied arguments.');
    elseif ~isequaln(actual, expected)
        result = recordTestResult(name, 'FAILED', ...
            sprintf('Expected %s, received %s.', ...
            valueDescription(expected), valueDescription(actual)));
    else
        result = recordTestResult(name, 'PASSED', ...
            sprintf('%s returned the expected result.', operation));
    end
end

function result = handleBoundsError(name, exception, errorExpected)
    if errorExpected
        result = recordTestResult(name, 'PASSED', ...
            sprintf('Constructor rejected the arguments: %s', exception.message));
    else
        result = recordTestResult(name, 'FAILED', exception.message);
    end
end

function description = valueDescription(value)
    if isempty(value)
        description = '[]';
    elseif isnumeric(value) || islogical(value)
        description = mat2str(value);
    else
        description = class(value);
    end
end
