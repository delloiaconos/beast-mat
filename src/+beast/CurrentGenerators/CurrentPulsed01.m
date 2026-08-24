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

function [ t_all, i_all ] = CurrentPulsed01( DeltaT, Tend, Ic, Id, Per, tc, td, trest )
%PULSEDCURRENT01 Summary of this function goes here
%   DeltaT: StepTime
%   Tend  : Max simulation Time
%   Ic    : Charge Current
%   Id    : Discharge Current

tzero = Per - (tc + td + trest);

t_T   = 0:DeltaT:Per;
y     = zeros( 1, length( t_T ) );

iid    = find( t_T >= tzero/2  & t_T <= tzero/2 + td);
y(iid) = abs( Id ) * ones( 1, length( iid ) );

iic    = find( t_T >= tzero/2 + td + trest  & t_T <= tzero/2 + td + trest + tc );
y(iic) = -abs( Ic ) * ones( 1, length( iic ) );


t_all = 0:DeltaT:Tend;
nT    = ceil( Tend./Per );

i_all = repmat( y, 1, nT );
i_all = i_all( 1:length(t_all) );
end
