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

OutputPath   = BEAST.ProcCpp.OutputPath;
InputPath    = BEAST.ProcCpp.InputPath;

exePath     = BEAST.ProcCpp.exePath;
exeName     = BEAST.ProcCpp.exeName;


if ( exist( InputPath, 'dir' ) ~=7 )
    display( 'Input Directory Error!' );
    break;
end

if ( exist( OutputPath, 'dir' ) ~=7 )
    mkdir( OutputPath );
end


% Get CellModelName
filename = [InputPath, 'MD_CellModelSel', '.txt'];
    fr = fopen( filename, 'rt' );
    Cpp.CellModelName = fscanf( fr, '%s' );
    fclose( fr );


% Get EstimationMethodName

filename = [InputPath, 'MD_EstimationMethodSel', '.txt'];
    fr = fopen( filename, 'rt' );
    Cpp.EstimationMethodName = fscanf( fr, '%s' );
    fclose( fr );
clear filename fr;


if isunix() == true
    
    exeFile    = [exePath, exeName];
    if( exist( exeFile, 'file' ) == false )
        display( ['ERROR: Executable "', exeFile, '"not found!'] );
        pause();
    end
    exeCommand = [exeFile  , ...
                    ' -i ' , InputPath, ...
                    ' -d ' , InputPath, ...
                    ' -o ' , OutputPath, ...
                    ' -m ' , Cpp.CellModelName, ... 
                    ' -e ' , Cpp.EstimationMethodName ];


    display( ['Executing: "' exeCommand '"' ] );
    system( exeCommand );

elseif ispc() == true
    
    exeFile    = [exePath, exeName, '.exe'];
    if( exist( exeFile, 'file' ) == false )
        display( ['ERROR: Executable "', exeFile, '"not found!'] );
        pause();
    end
    exeCommand = [exeFile  , ...
                    ' -i ' , InputPath, ...
                    ' -d ' , InputPath, ...
                    ' -o ' , OutputPath, ...
                    ' -m ' , Cpp.CellModelName, ... 
                    ' -e ' , Cpp.EstimationMethodName ];

    exeCommand = strrep( exeCommand, '/', '\' );
    display( ['Executing: "' exeCommand '"' ] );
    system( exeCommand );
end
clear OutputPath InputPath exePath exeName exeCommand