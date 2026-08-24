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

function BINexport_MATinteger(matrix,filename);

% Esporta su *filename* (binario) la matrice INTEGER *matrix* 
% conversione INTEGER (fortran) <-> int32 (matlab)

ind     = fopen(filename,'w');
ncounta = fwrite(ind,matrix,'int32');
          fclose(ind);
return 
