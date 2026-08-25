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

function mtx = BINimport_MATdouble(fname)

    % Importa da *fname* (binario) la matrice DOUBLE *matrix* 
    % conversione DOUBLE (fortran) <-> 2 x double (matlab)
    
    try
        fid = fopen(fname);
        [vect,~] = fread(fid,'float64');
        fclose(fid);
    catch ex
        warning( "Unable to open file: '%s'", fname );
        vect = [];
    end                       
    
    n     = length(vect);
    nsize = sqrt(n);
    mtx   = reshape(vect,nsize,nsize);
return 

