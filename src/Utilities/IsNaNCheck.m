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

function IsNaNCheck(mat,iRow,RowLabel)
    isnanloc = isnan(mat(iRow,:));
    idxnan = find(isnanloc);
    
    if ~isempty(idxnan)
        idxfirts = idxnan(1);
        dispError(['* NaN error in:',RowLabel,' from idx=',int2str(idxfirts)]); 
    else
        dispInfo(['* OK: ',RowLabel]); 
    end

end