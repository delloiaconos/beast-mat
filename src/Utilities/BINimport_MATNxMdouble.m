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

function matrix = BINimport_MATNxMdouble(filename,nn,mm);

% Importa da *filename* (binario) la matrice DOUBLE *matrix* 
% conversione DOUBLE (fortran) <-> 2 x double (matlab)

ind              = fopen(filename);
[vector,ncounta] = fread(ind,'float64');
                   fclose(ind);
ncard  = length(vector);
if ncard~=nn*mm
    disp 'ERROR 10 in BINimport_MATNXMdouble'
    disp 'Please STOP!'
    pause
end

matrix = reshape(vector,nn,mm);
return 

