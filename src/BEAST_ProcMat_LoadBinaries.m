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

InputPath = BEAST.ProcMat.InputPath;
BinaryExt = BEAST.ProcMat.BinInputExt;


filename = [InputPath, 'MD_deltat', BinaryExt];
	MD.deltat = BINimport_VECdouble( filename );

filename = [InputPath, 'MD_t_all', BinaryExt];
	MD.t_all = BINimport_VECdouble( filename );
	npoints = length( MD.t_all );
    MD.Nt = npoints;
    
filename = [InputPath, 'MD_u_all', BinaryExt];        % matrice
    MD.u_all =  BINimport_MAT_Ndouble( filename,  npoints );	

filename = [InputPath, 'MD_yXP_all', BinaryExt];       % matrice
    MD.yXP_all = BINimport_MAT_Ndouble( filename,  npoints );

filename = [InputPath, 'MD_x0', BinaryExt];
    MD.x0 = BINimport_VECdouble( filename );

filename = [InputPath, 'MD_p0', BinaryExt];
    MD.p0 = BINimport_VECdouble( filename );


clear npoints;

% CellModel Selection
filename = [InputPath, 'MD_CellModelSel', '.txt'];
    fr = fopen( filename, 'rt' );
    MD.CellModelSel = fscanf( fr, '%s' );
    fclose( fr );

%% Initialize and load Cell Model!

MDobj = CellModels.Initialize( InputPath, MD.CellModelSel, 'MD' );



% EstimationMethodSel
filename = [InputPath, 'MD_EstimationMethodSel', '.txt'];
    fr = fopen( filename, 'rt' );
    MD.EstimationMethodSel = fscanf( fr, '%s' );
    fclose( fr );
    

clear filename fr;
clear InputPath BinaryExt;


