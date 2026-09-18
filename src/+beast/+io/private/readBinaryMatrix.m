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


function matrix = readBinaryMatrix(filename, dimensions, precision, byteOrder)
%READBINARYMATRIX Read and reshape a raw column-major binary matrix.
%
%   A = beast.io.readBinaryMatrix(FILE, [M N], PRECISION) reads M*N values
%   and reshapes them into an M-by-N matrix. The raw storage order matches
%   MATLAB and column-major Fortran arrays.
%
%   One dimension may be -1 and is inferred from the number of values:
%       A = beast.io.readBinaryMatrix(FILE, [-1 N], "double");

    arguments
        filename   (1,1) string
        dimensions (1,2) double {mustBeInteger}
        precision  (1,1) string = "double"
        byteOrder  (1,1) string = "native"
    end

    if any(dimensions == 0) || any(dimensions < -1) || ...
            sum(dimensions == -1) > 1
        error("beast:io:InvalidDimensions", ...
            "Dimensions must be positive integers with at most one -1.");
    end

    vector = readBinaryVector(filename, precision, byteOrder);
    valueCount = numel(vector);

    inferredIndex = find(dimensions == -1, 1);
    if ~isempty(inferredIndex)
        knownIndex = 3 - inferredIndex;
        knownSize = dimensions(knownIndex);
        if mod(valueCount, knownSize) ~= 0
            error("beast:io:DimensionMismatch", ...
                ["File contains %d values, which is not divisible by " ...
                 "the known dimension %d."], valueCount, knownSize);
        end
        dimensions(inferredIndex) = valueCount / knownSize;
    elseif prod(dimensions) ~= valueCount
        error("beast:io:DimensionMismatch", ...
            "Expected %d values for a %d-by-%d matrix, but found %d.", ...
            prod(dimensions), dimensions(1), dimensions(2), valueCount);
    end

    matrix = reshape(vector, dimensions);
end
