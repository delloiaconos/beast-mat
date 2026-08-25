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

function mtx = BINimport_MATNxMdouble(fname,nn,mm)

    % Importa da *filename* (binario) la matrice DOUBLE *matrix* 
    % conversione DOUBLE (fortran) <-> 2 x double (matlab)

    try
        ind      = fopen(fname);
        [vect,~] = fread(ind,'float64');
        fclose(ind);
    catch ex
        warning( "Unable to open file: '%s'", fname );
        vect = [];
    end                       
    
    ncard  = length(vect);
    if ncard~=nn*mm
        disp( 'BINimport_MATNXMdouble' );
        disp( 'Please STOP!' );
        pause();
    end

    mtx = reshape(vector,nn,mm);
return 

