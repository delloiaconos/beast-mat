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

function printTestResults(results)
%PRINTTESTRESULTS Prints all the test results.
%   Detailed explanation goes here
    statuses = {results.status};

    fprintf('\nCellModel test summary: %d passed, %d skipped, %d failed\n', ...
        sum(strcmp(statuses, 'passed')), ...
        sum(strcmp(statuses, 'skipped')), ...
        sum(strcmp(statuses, 'failed')));
    
    for index = 1:numel(results)
        fprintf('[%s] %s: %s\n', ...
            upper(results(index).status), ...
            results(index).name, ...
            results(index).message);
    end
end