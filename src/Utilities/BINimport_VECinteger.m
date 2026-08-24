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
function vector = BINimport_VECdouble(filename);

% Importa da *filename* la matrice (binario) la matrice DOUBLE PRECISION *matrix* 

ind              = fopen(filename);
[vector,ncounta] = fread(ind,'int32');
                   fclose(ind);
return % ==================================================================

