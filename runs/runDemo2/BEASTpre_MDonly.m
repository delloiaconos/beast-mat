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

close all hidden;
clear all;
clc;


BEAST.LaunchDir               = pwd;
BEAST.BasePath                = '../../' ;

BEAST.Paths                   = { 'mfiles/', ...
                                 'mfiles/CellModels/', ...
				                 'mfiles/Utilities/', ...
                                 'mfiles/CurrentGenerators/'};

for ii=1:length( BEAST.Paths )
	addpath( [BEAST.BasePath BEAST.Paths{ii}] );
end
clear ii;

disp( 'Changing settings....' );


load( 'Data/Benchmark15.mat');

BEASTpre_SettingCovariance
BEASTpre_SettingMD
%% EXPORT TO FILES


%MDCellModelSel = '';
EstimationMethodSel = 'EKFDUALTSE';

run( 'BEASTpre_Export' );

disp( 'Now You can RUN BEAST!' );
disp( 'Running BEAST!' );

BEAST

