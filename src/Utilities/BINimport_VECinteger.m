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

% =========================================================================
function vect = BINimport_VECinteger(fname)
    % Importa da *fname* la matrice (binario) la matrice DOUBLE PRECISION *matrix* 

    try
        fid      = fopen(fname);
        [vect,~] = fread(fid,'int32');
        fclose(fid);
    catch ex
        warning( "Unable to open file: '%s'", fname );
        vect = [];
    end  

return 
