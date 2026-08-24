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

function matrix = BINimport_MATdouble(filename);

% Importa da *filename* (binario) la matrice DOUBLE *matrix* 
% conversione DOUBLE (fortran) <-> 2 x double (matlab)

ind              = fopen(filename);
%[a0,ncount0]     = fread(ind,1,'float32');
[vector,ncounta] = fread(ind,'float64');
                   fclose(ind);
n     = length(vector);
nsize  = sqrt(n);
matrix = reshape(vector,nsize,nsize);
return 


% function L=read_mat(file);
% %read from the binary file ftnind the complex inductance matrix
% %L(1:nlatac,1:nlatac)
% ind=fopen(file);
% [a0,ncount0]=fread(ind,1,'float32');
% [a,ncounta]=fread(ind,inf,'float64');
% n=length(a);
% nlatac=sqrt(n);
% L=a(1:n);
% clear a
% L=reshape(L,nlatac,nlatac);
% fclose(ind);

% ind              = fopen(filename);
% for ii=1:16*16
%     [a0,ncount0]=fread(ind,1,'float64');
%     if abs(a0)>1e15
%         a0
%         ii
%         pause
%     end
% end