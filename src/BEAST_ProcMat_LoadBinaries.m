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


fname = [InputPath, 'MD_deltat', BinaryExt];
	MD.deltat = beast.io.readDoubleVector( fname );

fname = [InputPath, 'MD_t_all', BinaryExt];
	MD.t_all = beast.io.readDoubleVector( fname );
	npoints = length( MD.t_all );
    MD.Nt = npoints;
    
fname = [InputPath, 'MD_u_all', BinaryExt];        % matrice
    MD.u_all =  beast.io.readDoubleMatrix( fname, [-1, npoints] );

fname = [InputPath, 'MD_yXP_all', BinaryExt];       % matrice
    MD.yXP_all = beast.io.readDoubleMatrix( fname, [-1, npoints] );

fname = [InputPath, 'MD_x0', BinaryExt];
    MD.x0 = beast.io.readDoubleVector( fname );

fname = [InputPath, 'MD_p0', BinaryExt];
    MD.p0 = beast.io.readDoubleVector( fname );


clear npoints;

% CellModel Selection
fname = [InputPath, 'MD_CellModelSel', '.txt'];
    fr = fopen( fname, 'rt' );
    MD.CellModelSel = fscanf( fr, '%s' );
    fclose( fr );

%% Initialize and load Cell Model!

MDobj = beast.CellModels.Initialize( InputPath, MD.CellModelSel, 'MD' );



% EstimationMethodSel
fname = [InputPath, 'MD_EstimationMethodSel', '.txt'];
    fr = fopen( fname, 'rt' );
    MD.EstimationMethodSel = fscanf( fr, '%s' );
    fclose( fr );
    

clear fname fr;
clear InputPath BinaryExt;


