close all; clear all; clc;

%% Include BEAST paths
base_path = '../';
beast_paths = { 'src/', 'src/Utilities/', 'src/Debug/' };
                  
for ii=1:length( beast_paths )
	addpath( fullfile( base_path, beast_paths{ii}) );
end
clear ii;

className = "beast.CellModels.H0F0A";

myCoeffs = struct();
myCoeffs.Qn_Ah  = 1.0;
myCoeffs.eta    = 1.0; 
myCoeffs.soc    = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]; 
myCoeffs.ocv0   = [2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.0];
myCoeffs.ocv1   = diff( myCoeffs.soc ) ./  diff( myCoeffs.ocv0 ); 

cellmodel = str2func(className);

coefficients = eval( sprintf( "%s.Coefficients", className ) );
Nx = eval( sprintf( "%s.Nx", className ) );
Np = eval( sprintf( "%s.Np", className ) );
Nu = eval( sprintf( "%s.Nu", className ) );
Ny = eval( sprintf( "%s.Ny", className ) );

%% Remove BEAST paths
for ii=1:length( beast_paths )
	rmpath( fullfile( base_path, beast_paths{ii}) );
end
clear ii;