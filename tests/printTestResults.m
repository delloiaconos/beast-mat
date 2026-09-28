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

function printTestResults(results, printPassed)
%PRINTTESTRESULTS Prints the test results.
%   PRINTTESTRESULTS(RESULTS) prints the summary and every test result.
%   PRINTTESTRESULTS(RESULTS, PRINTPASSED) suppresses individual PASSED
%   entries when PRINTPASSED is false.  The summary is always printed.
    if nargin < 2
        printPassed = true;
    end

    statuses = {results.status};

    fprintf('\nCellModel test summary: %d passed, %d skipped, %d failed\n', ...
        sum(strcmp(statuses, 'PASSED')), ...
        sum(strcmp(statuses, 'SKIPPED')), ...
        sum(strcmp(statuses, 'FAILED')));
    
    for index = 1:numel(results)
        if ~printPassed && strcmp(results(index).status, 'PASSED')
            continue;
        end

        fprintf('[%s] %s: %s\n', ...
            upper(results(index).status), ...
            results(index).name, ...
            results(index).message);
    end
end
