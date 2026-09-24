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

function results = test_estimators( results )
    % CONSTANTS
    myCoeffs = struct();
    myCoeffs.Qn_Ah  = 1.0;
    myCoeffs.eta    = 1.0; 
    myCoeffs.soc    = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]; 
    myCoeffs.ocv0   = [2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.0];
    myCoeffs.ocv1   = diff( myCoeffs.soc ) ./  diff( myCoeffs.ocv0 ); 
    myCoeffs.deltatfix = 1.0;
    
    % TESTS
    listCM = beast.CellModels.listCellModels();
    listES = beast.Estimators.listEstimators();
    
    for ii = 1:numel( listES )
        shortES = listES{ii};
    
        fprintf( "Evaluating class '%s'.\n", shortES );
        [esClass, esName] = beast.Estimators.selectEstimator(shortES);
    
        for jj = 1:numel( listCM )
            shortCM = listCM{jj};
        
            fprintf( "Initializing class '%s'.\n", shortCM );
        
            [cmClass, cmName] = beast.CellModels.selectCellModel(shortCM);
            
            coefficients = eval( sprintf( "%s.coeffNames", cmName ) );
            Nx = eval( sprintf( "%s.Nx", cmName ) );
            Np = eval( sprintf( "%s.Np", cmName ) );
            Nu = eval( sprintf( "%s.Nu", cmName ) );
            Ny = eval( sprintf( "%s.Ny", cmName ) );
            
            myCov = struct();
            myCov.sxV = eye( Nu, Nu ).*rand( Nu, Nu );
            myCov.sxW = eye( Nx, Nx ).*rand( Nx, Nx );
            myCov.spR = eye( Np, Np ).*rand( Np, Np );
            myCov.spE = eye( Ny, Ny ).*rand( Ny, Ny );
                
            objCM = cmClass( myCoeffs, myCov, myCoeffs.deltatfix );
            
            
            try
                objEST = esClass( objCM, myCoeffs.deltatfix );
                clear objEST objCM;
                
                results(end + 1) = recordTestResult( ...
                    esName, 'PASSED', ...
                    sprintf( "Constructor initialized successfully with '%s'", cmName ) );
            catch exception
                results(end + 1) = recordTestResult( ...
                    cmName, 'FAILED', ...
                    exception.message);
                    continue;
            end

        end
    end

end

