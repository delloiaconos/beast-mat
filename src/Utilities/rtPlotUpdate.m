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

function rtPlotUpdate( figHandler, lineHandler, textHandler, xdata, ydata, varName )

    set( lineHandler, 'xdata', xdata, 'ydata', ydata );
    
    %Construct the strings
    %ypos = get( figHandler, 'ylim' ); 

    
    tpos = get( textHandler, 'Position' );
    
    y_min = min( ydata );
    y_max = max( ydata );
    
    if( y_min == y_max )
        y_max = y_min + 1e-10;
    end
    
    set( figHandler, 'ylim', [y_min y_max] ); 
    px = tpos(1);
    py = 1/4*(y_max-y_min) + y_min;
    pz = tpos(3);
    
    str1 = sprintf( '%6s : %5.3e', 'Time', xdata(end) );
    str2 = sprintf( '%6s : %5.3e', varName , ydata(end) );
    
    set( textHandler, 'Position', [px py pz] );
    set( textHandler, 'String', {str1, str2} );
    
end