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

%% LiPo 350mAh UNISA
BTfilename = 'BEASTDataBT_SLB283452H';
load(BTfilename) 
pfixBattery = BTdata;
pfixBattery.eta      = 1.;
pfixBattery.Qn_Ah    = 0.35;
pfixBattery.R0       = 200e-3;
%pfixBattery.tau1     = min( [17.9 38.4 81.3] );
%pfixBattery.tau2     = max( [208 1.40e3 4.36e3 ] ); 
pfixBattery.R1       = 86e-3;
pfixBattery.C1       = 450;
pfixBattery.R2       = 150e-3;
pfixBattery.C2       = 8.5e+3;


%% Plot della SOC-OCV
if PlotData.Enable.PlotPreliminary ==1
    figure(2);
    plot(pfixBattery.soc,pfixBattery.ocv0);
    xlabel 'State of Charge SOC';
    ylabel(['open circuit voltage OCV (V)']); 
end%if iPreliminaryPlot
    
