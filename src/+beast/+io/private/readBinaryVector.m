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


function vector = readBinaryVector(filename, precision, byteOrder)
%READBINARYVECTOR Read a raw binary file as a column vector.
%
%   V = beast.io.readBinaryVector(FILE, PRECISION) reads all values from
%   FILE using the specified FREAD precision, for example "double" or
%   "int32". Values are returned without changing their stored order.
%
%   V = beast.io.readBinaryVector(FILE, PRECISION, BYTEORDER) also selects
%   the byte ordering accepted by FOPEN, such as "native", "ieee-le", or
%   "ieee-be".

    arguments
        filename  (1,1) string
        precision (1,1) string = "double"
        byteOrder (1,1) string = "native"
    end

    [fid, message] = fopen(filename, "rb", byteOrder);
    if fid == -1
        error("beast:io:FileOpenFailed", ...
            "Unable to open '%s' for reading: %s", filename, message);
    end
    cleanup = onCleanup(@() fclose(fid));

    try
        vector = fread(fid, Inf, precision + "=>" + precision);
    catch exception
        error("beast:io:ReadFailed", ...
            "Unable to read '%s' using precision '%s': %s", ...
            filename, precision, exception.message);
    end
end
