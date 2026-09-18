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

function [t_all, i_all] = IPulseGenerator2( dd )
EnablePlot = 0;
% Current I positive for discharge

%%
% clear, clc
% dd.SOCperc_history = [100 00 100];
% dd.deltaSOC = 100;
% dd.deltat   = 1.;
% dd.tON      = 60*60;
% dd.tOFF     = 10*60;
% dd.Qnom     = 2.*3600;

nSOC = length(dd.SOCperc_history );
SOC1old = dd.SOCperc_history (1);
SOCsteps = [SOC1old];
for iInterval = 1:nSOC-1
    disp '----'
    SOC1 = SOC1old
    SOC2 = dd.SOCperc_history (iInterval+1);
    
    % modifica SOC2 se necessario
    if SOC1<SOC2
        vectemp = SOC1:dd.deltaSOC:SOC2;
    elseif SOC1>SOC2
        vectemp = SOC1:-dd.deltaSOC:SOC2;
    end
    SOCsteps = [SOCsteps vectemp(2:end)];
    SOC2 = vectemp(end)
    
    SOC1old = SOC2;
end

if EnablePlot == 1
    figure(99);
    plot(SOCsteps,'r.-')
end

dSOCpulse = diff(SOCsteps);

nptsON   = floor(dd.tON/dd.deltat);
nptsOFF  = floor(dd.tOFF/dd.deltat);
nPulse = length(dSOCpulse);
IPulse = -dSOCpulse/100.*dd.Qnom/(nptsON*dd.deltat);

t_all = [];
i_all = [];
for kPulse=1:nPulse

    tloc = 0:dd.deltat:(nptsON+nptsOFF-1)*dd.deltat;
    nt = length(t_all);
    if nt == 0
        toffset = 0;
    else
        toffset = t_all(nt)+dd.deltat;
    end
    
    t_all = [t_all tloc+toffset];
    i_all = [i_all IPulse(kPulse)*ones(1,nptsON) zeros(1,nptsOFF) ];
end

if EnablePlot ==1
    figure(98);
    plot(t_all/3600,i_all,'k-');
end

end%function
