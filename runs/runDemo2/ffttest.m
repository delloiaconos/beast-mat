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

%% FFT Test

load( 'Data/Benchmark03.mat', 'XP' );

t_all = XP.t_all;
u_all = XP.u_all;
y_all = XP.y_all;

clear XP;

DeltaT = mean( diff( t_all ) );

Fs = 1/DeltaT;
L = length(t_all);                     % Length of signal

figure(1);
plot(t_all/60, u_all)
title('Current [A]')
xlabel('Time [min]')


NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(u_all,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);

figure(2)
% Plot single-sided amplitude spectrum.
plot(f,2*abs(Y(1:NFFT/2+1))) 
title('Signal Amplitude')
xlabel('Frequency [Hz]')
ylabel('|Y(f)|')

Ydb = 20*log( 2*abs(Y(1:NFFT/2+1)));
figure( 3 );
semilogx(f, Ydb );
title('Signal Amplitude')
xlabel('Frequency [Hz]')
ylabel('|Y(f)| [db]')
