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
    %ESTIMATOR Super Class fot all estimator class implementation.
    %   
    
    properties(Constant, Abstract)
        ExportableVars;
        FilterName;
    end

    properties(SetAccess=immutable, GetAccess=public, Abstract)
        Nx; Np; Nu; Ny;
    end

    properties(Constant, GetAccess=public)
        ExportableVarsFields = {'ClassVar', 'Size', 'ExportName', 'Export', 'FunHandler'};
    end
    
    methods(Access=public, Abstract)
        initialize( obj, x0, p0, uold, yXPold, told );
        step( obj, unew, yXPnew, tnew );
    end
    
end

