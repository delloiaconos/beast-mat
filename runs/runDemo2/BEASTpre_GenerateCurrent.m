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

%%
% Generazione e salvataggio dei vettori dati per l'esecuzione 
% dell'algoritmo. 
%
%
% Modified by SDI 		- 2015.07.02
% Created  by SDI      - 2013.10.13
%

DeltaT = 0.25;
Tmax   = 11*60; %sec

Qn_Ah  = 350e-3;

DeltaSoC = 0.3;

iisel = 150;


if iisel == 10
    
    dispInfo( 'benchmark 01' );
    
    
    Ic  = 1*Qn_Ah; % Corrente carica
    Id  = 5*Qn_Ah; % Corrente scarica
    Per   = 7.5*60;    % Periodo
    tc    = 2.5*60;
    td    = 2.5*60;
    trest = 1.25*60;
    
    [ t_all, i_all ] = beast.CurrentGenerators.CurrentPulsed01( DeltaT, Tmax, Ic, Id, Per, tc, td, trest );
elseif iisel == 15
    Ic  = 1*Qn_Ah; % Corrente carica
    Id  = 5*Qn_Ah; % Corrente scarica
    Per   = 7.5*60;    % Periodo
    tc    = 2.5*60;
    td    = 2.5*60;
    trest = 1.25*60;
    
    [ t_all, i_all ] = beast.CurrentGenerators.CurrentPulsed01( DeltaT, Tmax, Ic, Id, Per, tc, td, trest );
    
    i_all = -i_all;
elseif iisel == 20
    
    disp( 'benchmark 02' );
    
    Tmax     = 15*60;
    
    UDDSdata = load( './Data/uddscol.mat' ); 

    t_all  =  UDDSdata.t_all;
    i_norm =  UDDSdata.i_Batt;
    clear UDDSdata;    
    
    npt    = find( t_all <= Tmax, 1, 'last' );
    
    t_all  = t_all(1:npt );
    i_norm = i_norm(1:npt);
    
    i_all  =  -5.05*i_norm;
    
    
elseif iisel == 30
    disp( 'benchmark 03' );
    
    Tmax     = 15*60;
    
    UDDSdata = load( './Data/uddscol.mat' ); 

    t_all  =  UDDSdata.t_all;
    i_norm =  UDDSdata.i_Batt;
    clear UDDSdata;    
    
    npt    = find( t_all <= Tmax, 1, 'last' );
    
    t_all  = t_all(1:npt );
    i_norm = i_norm(1:npt);
    i_all  =  -5.05*i_norm;
    
    
    istr = find( t_all/60 >= 5.7, 1, 'first' );
    iend = find( t_all/60 <= 11.5, 1, 'last'  );
    
    Ic  = 1*Qn_Ah; % Corrente carica
    Id  = 5*Qn_Ah; % Corrente scarica
    Per   = 7.5*60;    % Periodo
    tc    = 2.5*60;
    td    = 2.5*60;
    trest = 1.25*60;
    
    [ t_pulse, i_pulse ] = beast.CurrentGenerators.CurrentPulsed01( DeltaT, Per, Ic, Id, Per, tc, td, trest );
    
    i_all( istr:iend ) = i_pulse(1:(iend-istr+1) );
    
elseif iisel == 40
    disp( 'benchmark 04' );
    
    Tmax     = 15*60;
    
    UDDSdata = load( './Data/uddscol.mat' ); 

    t_udds  =  UDDSdata.t_all;
    i_udds =  UDDSdata.i_Batt;
    clear UDDSdata;    
    i_udds  =  -5.05*i_udds;
    n_udds  = length( i_udds );
    
    
 
    
    Ic  = 1*Qn_Ah; % Corrente carica
    Id  = 5*Qn_Ah; % Corrente scarica
    Per   = 7.5*60;    % Periodo
    tc    = 2.5*60;
    td    = 2.5*60;
    trest = 1.25*60;
    
    [ t_all, i_all ] = beast.CurrentGenerators.CurrentPulsed01( DeltaT, Tmax, Ic, Id, Per, tc, td, trest );
    npts = length( t_all );
    
    %istr = find( t_all/60 >= Per, 1, 'first' );
    iend = find( t_all >= Per, 1, 'first'  );

    i_all( iend:end ) = i_udds(1:(npts-iend+1) );
    
elseif iisel == 50
    disp( 'benchmark 05' );
    %Gradino 
    Id  = 5*Qn_Ah; % Corrente scarica
    
    t_all = 0:DeltaT:Tmax;
    i_all = zeros( 1, length( t_all ) );
    
    ii = find( t_all > 2*60, 1, 'first' );
    
    i_all(ii:end) = Id*ones( 1, length( i_all(ii:end) ) );
    
elseif iisel == 100
    disp( 'benchmark 10' );
    %Sinusoide
    
    Id  = 0.5*Qn_Ah; % Corrente scarica
    Per = 86e-3*450; %R1*C1
    Nper = 320;
    
    t_all = 0:DeltaT:(Per*Nper);
    i_all = zeros( 1, length( t_all ) );
    
    
    i_all = Id*sin( 2*pi/Per * t_all );

elseif iisel == 110
    disp( 'benchmark 11' );
    %Onda Quadra
    
    Id  = 0.5*Qn_Ah; % Corrente scarica
    Per = 86e-3*450; %R1*C1
    Nper = 320;
    
    t_all = 0:DeltaT:(Per*Nper);
    i_all = zeros( 1, length( t_all ) );
    
    
    i_all = Id*square( 2*pi/Per * t_all );

elseif iisel == 120
    disp( 'benchmark 12' );
    %Onda Quadra
    
    Id  = 0.5*Qn_Ah; % Corrente scarica
    Per = 86e-3*450/20; %R1*C1/20
    Nper = 320*20;
    
    t_all = 0:DeltaT:(Per*Nper);
    i_all = zeros( 1, length( t_all ) );
    
    
    i_all = Id*square( 2*pi/Per * t_all );

elseif iisel == 130
    disp( 'benchmark 13' );
    %Onda Quadra
    
    Id  = 0.5*Qn_Ah; % Corrente scarica
    Per = 86e-3*450*20; %R1*C1/20
    Nper = 32;
    
    t_all = 0:DeltaT:(Per*Nper);
    i_all = zeros( 1, length( t_all ) );
    
    
    i_all = Id*square( 2*pi/Per * t_all );
    
elseif iisel == 150
    disp( 'benchmark 15' );
    
    Tmax     = 50*60;
    
    UDDSdata = load( './Data/uddscol.mat' ); 

    t_all  =  0:DeltaT:Tmax;
    i_norm =  UDDSdata.i_Batt;
    clear UDDSdata;    
    
%    npt    = find( t_all <= Tmax, 1, 'last' );
    
    
%    t_all  = t_all(1:npt );
    i_all  =  -5.05*[i_norm i_norm(1:600)];
    
    %istr = find( t_all/60 >= 25, 1, 'first' );
    %iend = find( t_all/60 <= 39, 1, 'last'  );
    
    Ic  = 1*Qn_Ah; % Corrente carica
    Id  = 5*Qn_Ah; % Corrente scarica
    Per   = 14*60;    % Periodo
    tc    = 13*60;
    td    = 0*60;
    trest = 1*60;
    
    [ t_pulse, i_pulse ] = beast.CurrentGenerators.CurrentPulsed01( DeltaT, Per, Ic, Id, Per, tc, td, trest );
    
    i_all = [i_all i_pulse -5.05*i_norm(600:end) ];
    
    i_all = i_all(1:length(t_all) );
    
end

fprintf( 'Npts  %d\n', length( t_all ) );
fprintf( 'Min   %f\n',  min( i_all ) );
fprintf( 'Max   %f\n',  max( i_all ) );
fprintf( 'Mean  %f\n',  mean( i_all ) );
fprintf( 'RMS   %f\n',  sqrt( mean( i_all .^2 ) ) );



XP.deltat = DeltaT;
XP.t_all  = t_all;
XP.u_all  = i_all;
XP.Nt     = length( t_all );
clear DeltaT t_all i_all;

figure( 1234 )
plot( XP.t_all/60, XP.u_all );
title( 'Generated Current' );
xlabel( 'Time [min]' );
ylabel( 'Current [A]' );

