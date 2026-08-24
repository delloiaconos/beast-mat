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

classdef Estimator < handle
    %ESTIMATOR Super Class fot all estimator methods
    %   
    
    properties( Constant, Abstract )
        ExportableVars;
        FilterName;
    end
    
    properties( Constant, GetAccess = public )
        ExportableFields = {'ClassVar', 'Size', 'ExportName', 'Export', 'FunHandler'};
    end
    
    methods( Abstract )
        Initialize( obj, x0, p0, uold, yXPold, told );
        Step( obj, unew, yXPnew, tnew );
    end
    
end

