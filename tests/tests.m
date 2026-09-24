close all; clear all; clc;

%% Include BEAST paths
base_path = '../';
beast_paths = { 'src/', 'src/Utilities/', 'src/Debug/' };
                  
for ii=1:length( beast_paths )
	addpath( fullfile( base_path, beast_paths{ii}) );
end
clear ii;

results = struct('name', {}, 'status', {}, 'message', {});

results = test_cell_models( results ); 
results = test_estimators( results );

printTestResults( results );

%% Remove BEAST paths
for ii=1:length( beast_paths )
	rmpath( fullfile( base_path, beast_paths{ii}) );
end
clear ii;