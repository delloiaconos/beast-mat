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

function matrix = readDoubleMatrix(filename, dimensions)
%READDOUBLEMATRIX Read a raw binary double-precision matrix.
% Use -1 for one dimension to infer it from the stored value count.
    arguments
        filename   (1,1) string
        dimensions (1,2) double {mustBeInteger}
    end
    matrix = readBinaryMatrix(filename, dimensions, "double", "native");
end
