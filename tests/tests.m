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

close all; clear all; clc;

%% Include BEAST paths
base_path = '../';
beast_paths = { 'src/', 'src/Utilities/', 'src/Debug/' };
                  
for ii=1:length( beast_paths )
	addpath( fullfile( base_path, beast_paths{ii}) );
end
clear ii;

results = struct('name', {}, 'status', {}, 'message', {});

results = test_cell_models( results ); 
results = test_estimators( results );

printTestResults( results );

%% Remove BEAST paths
for ii=1:length( beast_paths )
	rmpath( fullfile( base_path, beast_paths{ii}) );
end
clear ii;