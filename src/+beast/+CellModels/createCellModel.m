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

function [ cellmodel ] = createCellModel( cmSelector, coeffs, cov, deltat )
	   
    [cmClass, ~] = beast.CellModels.selectCellModel( cmSelector );
    
    if( cmClass == null )
        dispError( "CellModelInit - CellModel '%s' not recognized!", cmSelector );
        pause();
    end
    
    cellmodel = cmClass( coeffs, cov, deltat );
    
end


