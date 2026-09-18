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

function [xx_all,yy_all] = TSim(AA,AAobj,flowflag,ifigCounter,iPlot);

if flowflag.simulation == 1;
%% Generation
xx_all = zeros(AAobj.Nx,AA.Nt);
yy_all = zeros(AAobj.Ny,AA.Nt);
tic

xxold = AA.x0;
ppold = AA.p0;
hw = waitbar(0,['Generating simulation data for:',AA.title]);
for kk = 1:AA.Nt
    waitbar(kk/AA.Nt,hw);
    uuold        = AA.u_all(kk);
    xxnew        = AAobj.f0(xxold, ppold, uuold, AA.deltat  );
    xxnew        = AAobj.CoerceStateCompatibility( xxnew );
    yyold        = AAobj.g0(xxold, ppold, uuold, AA.deltat  );
    xx_all(:,kk) = xxold;
    yy_all(:,kk) = yyold;
    xxold = xxnew;
end
close(hw);
disp(['... simulation data for:',AA.title,' generated!']);

%% Plot
if iPlot==1
% ... state 
for istate = 1:AAobj.Nx
    ifigCounter = ifigCounter+1;
    figure(ifigCounter);
    plot(AA.t_all/3600,xx_all(istate,:),'-m');
    xlabel 'time (h)';
    ylabel(['state no.',int2str(istate)]); 
    title(AA.title);
end

% ... output voltage
ifigCounter = ifigCounter+1;
figure(ifigCounter);
plot(AA.t_all/3600,yy_all(1,:),'-r');
xlabel 'time (h)';
ylabel 'output voltage (V)'
title( AA.title );

% ... input current
ifigCounter = ifigCounter+1;
figure(ifigCounter);
plot(AA.t_all/3600,AA.u_all(1,:),'-k');
xlabel 'time (h)';
ylabel 'input current (A)'
title( AA.title );
end
end%if flowflag.simulation == 1;
%%
end