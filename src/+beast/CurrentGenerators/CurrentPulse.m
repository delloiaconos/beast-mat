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

% 
% Spice Example 
%*             I1 I2  Td Tr    Tf    Tw    Per. 
% Is 1 0 PULSE(0V 10V 0s 100ms 100ms 900ms 2s)

function [ t_all, i_all ] = CurrentPulse( DeltaT, Tend, I1, I2, Td, Tr, Tf, Tw, Per )
%PULSEDCURRENT01 Summary of this function goes here
%   DeltaT: StepTime
%   Tend  : Max simulation Time
%   Ic    : Charge Current
%   Id    : Discharge Current

tPer   = 0:DeltaT:Per;
y      = I1*ones( length( tPer ), 1 );

isrt    = 1;
iend    = find( tPer <= Tr, 1, 'last' );
y(isrt:iend) = (I2-I1)/Tr*tPer(isrt:iend) + I1;
clear iir;

isrt   = iend + 1;
iend   = find( tPer > Tr & tPer <= Tr+Tw, 1, 'last' );
y(isrt:iend) = I2*ones( iend-isrt+1, 1 );


isrt   = iend + 1;
iend   = find( tPer > Tr+Tw & tPer <= Tr+Tw+Tf, 1, 'last' );
y(isrt:iend) = (I1-I2)/Tf*( tPer(isrt:iend) - (Tr+Tw) ) + I2;
clear iif;

t_all = 0:DeltaT:Tend;
iid   = find( t_all > Td , 1 );

nPer    = ceil( Tend./Per );

% Useful inline function: subindex of an array!
subindex = @(A,r,c) A(r:c); 

i_all = I1*ones( length(t_all),1  );
i_all( iid:end ) =  subindex( repmat( y, nPer, 1 ), 1, length(t_all)-iid+1 );

end

