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
        dispError( "CellModelInit - CellModel not recognized!" );
        pause;
    end
    
    cmCoefficients = eval( [cmName, '.Coefficients'] );
    
    coeffs = struct();
    
    for kk=1:length(cmCoefficients)
    	fname = [basepath, '/', prefix , '_pfix_', cmCoefficients{kk}, '.in'];
    	if exist( fname, 'file' ) ~= 2 
    		dispError( "CellModelInit - File '%s' not found!", fname );
        	pause;
    	else
    		fr = fopen(fname);
			[vector,~] = fread(fr,'double');
            fclose(fr);
            
            coeffs.(cmCoefficients{kk}) = vector;
    	end
    end
    
    cov = struct();
    
    fname = [basepath, '/', prefix , '_COV_spEvec', '.in'];
    if exist( fname, 'file' ) ~= 2 
    	dispError( "ERROR: CellModelInit - File '%s' not found!", fname );
        pause;
    else
    	fr = fopen(fname);
		[vector,~] = fread(fr,'double');
        fclose(fr);
    	
    	cov.spE = diag(vector);     
    end

    fname = [basepath, '/', prefix , '_COV_spRvec', '.in'];
    if exist( fname, 'file' ) ~= 2 
    	dispError( "ERROR: CellModelInit - File '%s' not found!", fname );
        pause;
    else
    	fr = fopen(fname);
		[vector,~] = fread(fr,'double');
        fclose(fr);
    	
    	cov.spR = diag(vector);     
    end    
    
    fname = [basepath, '/', prefix , '_COV_sxVvec', '.in'];
    if exist( fname, 'file' ) ~= 2 
    	dispError( "ERROR: CellModelInit - File '%s' not found!", fname );
        pause;
    else
    	fr = fopen(fname);
		[vector,~] = fread(fr,'double');
        fclose(fr);
    	
    	cov.sxV = diag(vector);     
    end
    
    fname = [basepath, '/', prefix , '_COV_sxWvec', '.in'];
    if exist( fname, 'file' ) ~= 2 
    	dispError( "ERROR: CellModelInit - File '%s' not found!", fname );
        pause;
    else
    	fr = fopen(fname);
		[vector,~] = fread(fr,'double');
        fclose(fr);
    	
    	cov.sxW = diag(vector);     
    end
    
    deltat = 0.0;
    fname = [basepath, '/', prefix , '_deltat', '.in'];
    if exist( fname, 'file' ) ~= 2 
    	dispError( "ERROR: CellModelInit - File '%s' not found!", fname );
        pause;
    else
    	fr = fopen(fname);
		[vector,~] = fread(fr,'double');
        fclose(fr);
    	
    	deltat = vector(1);     
    end
    
    cellmodel = cmClass( coeffs, cov, deltat );
end
    
