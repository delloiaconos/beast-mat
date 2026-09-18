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

if( exist('BEAST','var') ~= true )
    dispError( 'Unable to find "BEAST" structure' );
    keyboard();
    pause();
end


BEAST.Paths                   = { 'src/', ...
				                 'src/Utilities/', ...
                                 'src/Debug/' };

% Include paths                       
cd( BEAST.LaunchDir );
for ii=1:length( BEAST.Paths )
	addpath( [BEAST.BasePath BEAST.Paths{ii}] );
end
clear ii;

%% XPGen - Experiment Generator 
if fieldexists( 'BEAST', 'XPGen' ) && BEAST.XPGen.Run == true
    run( [BEAST.LaunchDir , '/BEASTpre.m'] );
end


%% MDGen - Model Generator 
if fieldexists( 'BEAST', 'MDGen' ) && BEAST.MDGen.Run == true
    run( [BEAST.LaunchDir , '/BEASTpre.m'] );
end

%% ProcMat - MATLAB Processing
if fieldexists( 'BEAST', 'ProcMat' ) && BEAST.ProcMat.Run == true
    run( 'BEAST_ProcMat' );
end

%% ProcCpp - External Processing
if fieldexists( 'BEAST', 'ProcCpp' ) && BEAST.ProcCpp.Run == true
    run( 'BEAST_ProcCpp' );
end

%% PostProc - Post Processing
if fieldexists( 'BEAST', 'PostProc' ) && BEAST.PostProc.Run == true
    run( 'BEAST_PostProc' );
end

%% Backup - End Backup Scripting
if fieldexists( 'BEAST', 'Backup' ) && BEAST.Backup.Run == true
    if( iscell( BEAST.Backup.ExternalCommand ) )
        for jj=1:length( BEAST.Backup.ExternalCommand )
             disp( ['[BEAST] Executing: "' BEAST.Backup.ExternalCommand{jj} '"'] );
             system( BEAST.Backup.ExternalCommand{jj} );
        end
        clear jj;
    else
        disp( ['[BEAST] Executing: "' BEAST.Backup.ExternalCommand '"'] );
        system( BEAST.Backup.ExternalCommand );
    end
end


% Remove paths
for ii=1:length( BEAST.Paths )
	rmpath( [BEAST.BasePath BEAST.Paths{ii}] );
end
clear ii;
