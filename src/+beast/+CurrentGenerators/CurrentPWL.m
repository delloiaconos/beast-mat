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

function [ t_all, i_all ] = CurrentPWL( DeltaT, Tend, t_vect, I_vect )
%CURRENTPWL Summary of this function goes here
%   Detailed explanation goes here

    t_all = 0:DeltaT:(max(t_vect) + DeltaT );
    i_all = I_vect(1)*ones( 1, length( t_all ) );

    if( t_vect(1) ~= 0 )
        t_vect = [0 t_vect];
        I_vect = [I_vect(1) I_vect];
    end    

    iim = 1;
    for kk = 1:(min([length(t_vect) length(I_vect)]) -1) 

        iip = find( t_all <  t_vect(kk+1) ,1, 'last' );
        
        mkk = ( I_vect(kk+1) - I_vect(kk) )./( t_all(iip) - t_all(iim) );
        
        i_all(iim:iip) = mkk*( t_all(iim:iip) - t_all(iim) ) + I_vect(kk);
        
        iim = iip;
    end

    iiend = iim;
    if( t_all(iiend) < Tend )
        
        t_end = t_all(iiend):DeltaT:Tend;
        
        npts = length( t_end );
        
        
        t_all = [t_all(1:iiend) t_end];
        i_all = [i_all(1:iiend) I_vect(kk+1)*ones( 1, npts )];
    else
        iiend = find( t_all <= Tend, 1, 'last' );
        
        t_all = t_all(1:iiend);
        i_all = i_all(1:iiend);
    end
    
end
