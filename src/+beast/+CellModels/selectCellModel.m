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

function [cmClass] = selectCellModel( shortName )
%SELECTCELLMODEL Select a specific model from its short name.
%   Detailed explanation goes here

    parts = strsplit( shortName, "." );
    listCellModels = beast.CellModels.listCellModels();

    if( any( strcmp(listCellModels, parts(end) ) ) )
        className = sprintf( "beast.CellModels.%s", string( parts(end) ) );
        cmClass = str2func(className);
    else
        dispError( "Cell Mode '%s' not found!", shortName );
        cmClass = null;
    end

end

