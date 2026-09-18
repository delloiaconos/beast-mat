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

function count = writeBinaryMatrix(filename, matrix, precision, byteOrder)
%WRITEBINARYMATRIX Write a matrix as raw column-major binary values.
%
%   COUNT = beast.io.writeBinaryMatrix(FILE, A, PRECISION) writes A in
%   MATLAB column-major order using an FWRITE precision such as "double"
%   or "int32". COUNT is the number of values written.

    arguments
        filename  (1,1) string
        matrix    {mustBeNumeric, mustBeNonempty}
        precision (1,1) string = "double"
        byteOrder (1,1) string = "native"
    end

    [fid, message] = fopen(filename, "wb", byteOrder);
    if fid == -1
        error("beast:io:FileOpenFailed", ...
            "Unable to open '%s' for writing: %s", filename, message);
    end
    cleanup = onCleanup(@() fclose(fid));

    try
        count = fwrite(fid, matrix, precision);
    catch exception
        error("beast:io:WriteFailed", ...
            "Unable to write '%s' using precision '%s': %s", ...
            filename, precision, exception.message);
    end

    if count ~= numel(matrix)
        error("beast:io:IncompleteWrite", ...
            "Only %d of %d values were written to '%s'.", ...
            count, numel(matrix), filename);
    end
end
