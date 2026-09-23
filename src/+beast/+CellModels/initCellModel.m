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

function [ cellmodel ] = initCellModel( cmSelector, basepath, prefix )
	   
    [cmClass, cmName] = beast.CellModels.selectCellModel( cmSelector );
    
    if( cmClass == null )
        dispError( "CellModelInit - CellModel '%s' not recognized!", cmSelector );
        pause;
    end
    
    cmCoefficients = eval( [cmName, '.Coefficients'] );
    
    coeffs = struct();
    
    for kk=1:length(cmCoefficients)
    	fName = fullfile( basepath, sprintf( "%s_pfix_%s.in", prefix, cmCoefficients{kk} ) );
    	if exist( fName, 'file' ) ~= 2 
    		dispError( "CellModelInit - File '%s' not found!", fName );
        	pause;
    	else
    		fr = fopen(fName);
			[vector,~] = fread(fr,'double');
            fclose(fr);
            
            coeffs.(cmCoefficients{kk}) = vector;
    	end
    end
    
    cov = struct();
    
    fnamebuild = @(str) fullfile( basepath, sprintf( "%s%s.in", prefix, str ) );

    fName = fnamebuild( "_COV_spEvec" );
    if exist( fName, 'file' ) ~= 2 
    	dispError( "CellModelInit - File '%s' not found!", fName );
        pause;
    else
    	fr = fopen(fName);
		[vector,~] = fread(fr,'double');
        fclose(fr);
    	
    	cov.spE = diag(vector);     
    end

    fName = fnamebuild( "_COV_spRvec" );
    if exist( fName, 'file' ) ~= 2 
    	dispError( "CellModelInit - File '%s' not found!", fName );
        pause;
    else
    	fr = fopen(fName);
		[vector,~] = fread(fr,'double');
        fclose(fr);
    	
    	cov.spR = diag(vector);     
    end    
    
    fName = fnamebuild( "_COV_sxVvec" );
    if exist( fName, 'file' ) ~= 2 
    	dispError( "CellModelInit - File '%s' not found!", fName );
        pause;
    else
    	fr = fopen(fName);
		[vector,~] = fread(fr,'double');
        fclose(fr);
    	
    	cov.sxV = diag(vector);     
    end
    
    fName = fnamebuild( "_COV_sxWvec" );
    if exist( fName, 'file' ) ~= 2 
    	dispError( "CellModelInit - File '%s' not found!", fName );
        pause;
    else
    	fr = fopen(fName);
		[vector,~] = fread(fr,'double');
        fclose(fr);
    	
    	cov.sxW = diag(vector);     
    end
    
    deltat = 0.0;
    fName = fnamebuild( "_deltat" );
    if exist( fName, 'file' ) ~= 2 
    	dispError( "CellModelInit - File '%s' not found!", fName );
        pause;
    else
    	fr = fopen(fName);
		[vector,~] = fread(fr,'double');
        fclose(fr);
    	
    	deltat = vector(1);     
    end
    
    cellmodel = cmClass( coeffs, cov, deltat );
end
    
