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

function [classNames] = listCellModels()
%LISTCELLMODELS Lists all the availables CellModels classes as string.
%   Detailed explanation goes here
    currentDirectory = fileparts(mfilename('fullpath'));
    classDirectory = currentDirectory;

    files = dir(fullfile(classDirectory, '*.m'));
    classNames = string.empty;

    for index = 1:numel(files)
        fileName = files(index).name;

        shortName = erase(fileName, '.m');
        fullName = ['beast.CellModels.' shortName];

        try
            classInfo = meta.class.fromName(fullName);

            if ~isempty(classInfo) && ~classInfo.Abstract
                classNames{end + 1} = shortName; %#ok<AGROW>
            end
        catch
            % Ignore files that are not MATLAB class definitions.
        end
    end
end

