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

%%%
% Files To EXPORT:
% 
% MD_t_all.in
% MD_u_all.in
% MD_yXP_all.in
% MD_x0.in
% MD_p0.in
% 
% CellModelSel.txt
% EstimationMethodSel.txt
% 
% MD_deltat.in
% COV_sxWvec.in
% COV_sxVvec.in
% COV_spRvec.in
% COV_spEvec.in
% pfix_Qn_Ah.in
% pfix_eta.in
% pfix_soc.in
% pfix_ocv0.in
% pfix_ocv1.in
% And all files required from battery model
%%%

%% percorsi e path
localFolder     = [pwd, '/'];
mfilesFolder    = [localFolder,'../../src/'];


addpath( [mfilesFolder,'CellModels/'] );
addpath( [mfilesFolder,'Estimators/'] );
addpath( [mfilesFolder,'Utilities/'] );
addpath( [mfilesFolder,'CurrentGenerators/'] );
addpath( [localFolder,'../../datafiles/'] );
addpath( mfilesFolder );

%% FLOW PARS TO BE SELECTED
PlotData.Enable.PlotPreliminary = 0;
PlotData.Enable.PlotXP          = 1;

FlowFlag.DataSel.UseExperimentalDataSet = 1;
FlowFlag.DataSel.CellModelIdenticalPars = 0;


%% LOAD DATA AND DATA DEFINITION ==========================================
EstimationMethodSel = 'EKFDUAL'; % EKFSTATE, EKFPARAMS, EKFDUAL, MIXALGORITHM, ENHANCEDMIXALGORITHM, OPENLOOP
XPCellModelSel      = 'R0R1C1R2C2';
MDCellModelSel      = 'R0R1C1R2C2';


%% Generate Current
%% Battery Settings...
BEASTpre_SettingCovariance
BEASTpre_SettingBatteryCharacteristic

% Genera Input
BEASTpre_GenerateCurrent
BEASTpre_SettingXPSimulated

MD = XP;
MD.yXP_all = XP.y_all;

save( 'Data/Benchmark15.mat');

figure( 999 )
subplot( 3,1,1 );
    title( 'Current' );
    plot( XP.t_all/60, XP.u_all );
subplot( 3,1,2 );
    title( 'Voltage' );
    plot( XP.t_all/60, XP.y_all );
subplot( 3,1,3 );
    title( 'SoC' );
    plot( XP.t_all/60, XP.x_all(1,:) );

