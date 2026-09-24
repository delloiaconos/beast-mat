function results = test_cell_models( results )
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
    
    for ii = 1:length( listCM )
        cmName = listCM{ii};

        [cmClass, cmName] = beast.CellModels.selectCellModel(cmName);
        
        coeffs = eval( sprintf( "%s.coeffNames", cmName ) );
        Nx = eval( sprintf( "%s.Nx", cmName ) );
        Np = eval( sprintf( "%s.Np", cmName ) );
        Nu = eval( sprintf( "%s.Nu", cmName ) );
        Ny = eval( sprintf( "%s.Ny", cmName ) );
        
        myCov = struct();
        myCov.sxV = eye( Nu, Nu ).*rand( Nu, Nu );
        myCov.sxW = eye( Nx, Nx ).*rand( Nx, Nx );
        myCov.spR = eye( Np, Np ).*rand( Np, Np );
        myCov.spE = eye( Ny, Ny ).*rand( Ny, Ny );
            
        try
            objCM = cmClass( myCoeffs, myCov, myCoeffs.deltatfix );
            clear objCM;
            
            results(end + 1) = recordTestResult( ...
                cmName, 'PASSED', ...
                'Constructor initialized successfully');
        catch exception
            results(end + 1) = recordTestResult( ...
                cmName, 'FAILED', ...
                exception.message);
            continue;
        end
        
    end

end