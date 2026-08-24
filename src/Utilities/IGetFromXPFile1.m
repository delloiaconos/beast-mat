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

function [t_all, i_all] = IGetFromXPFile1(XPfilename);
% Returns equispaced t,i vectors

load(XPfilename); % in XPdata
t_tmp = XPdata.tt;
i_tmp = XPdata.ii; 
nt_tmp = length(t_tmp);

t_all = linspace(t_tmp(1),t_tmp(end),nt_tmp);
i_all = interp1(t_tmp,i_tmp,t_all);

end%function
