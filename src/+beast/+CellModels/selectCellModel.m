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

function [cmClass, cmName] = selectCellModel( shortName )
%SELECTCELLMODEL Select a specific CellModel from its short name.
%   Detailed explanation goes here
    shortName = strtrim( shortName );
    shortName = upper( shortName );

    parts = strsplit( shortName, "." );
    listCellModels = beast.CellModels.listCellModels();

    if( any( strcmp(listCellModels, parts(end) ) ) )
        cmName = sprintf( "beast.CellModels.%s", string( parts(end) ) );
        cmClass = str2func(cmName);
    else
        dispError( "Cell Model '%s' not found!", shortName );
        cmName = "";
        cmClass = null;
    end

end

