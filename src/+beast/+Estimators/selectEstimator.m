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

function [esClass, esName] = selectEstimator( shortName )
%SELECTESTIMATOR\ Select a specific Estimator from its short name.
%   Detailed explanation goes here
    shortName = strtrim( shortName );
    %shortName = upper( shortName );

    parts = strsplit( shortName, "." );
    listEstimators = beast.Estimators.listEstimators();

    if( any( strcmp(listEstimators, parts(end) ) ) )
        esName = sprintf( "beast.Estimators.%s", string( parts(end) ) );
        esClass = str2func(esName);
    else
        dispError( "Estimator '%s' not found!", shortName );
        esName = "";
        esClass = null;
    end

end

