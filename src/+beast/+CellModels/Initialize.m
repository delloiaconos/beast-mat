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

function [ cellmodel ] = Initialize( basepath, cmSelector, prefix )
	   
    cmSelector = strtrim( cmSelector );
    cmSelector = upper( cmSelector );
    
    pckName    = 'CellModels';
    pckContent = what( pckName );
    pckClasses = pckContent.classes;

    cmName   = '';
    
    for ii=1:length( pckClasses )
        if strcmpi( cmSelector, pckClasses{ii} ) == true
            cmName = sprintf( '%s.%s', pckName, pckClasses{ii} );
            break;
        end
    end
    clear pckName pckContent pckClasses ii;
    
    if( strcmpi( cmName, '' ) ~= false )
        disp( 'ERROR: CellModelInit - CellModel not recognized!\n' );
        keyboard();
        pause;
    end
    
    cmRequired = eval( [cmName, '.Required'] );
    
    pfix = struct();
    
    for kk=1:length(cmRequired)
    	fname = [basepath, '/', prefix , '_pfix_', cmRequired{kk}, '.in'];
    	if exist( fname, 'file' ) ~= 2 
    		disp( ['ERROR: CellModelInit - File "', fname, '"Not Found!\n'] );
        	pause;
    	else
    		fr = fopen(fname);
			[vector,n] = fread(fr,'double');
            fclose(fr);
            
            %dispDebug( ['pfix.', cmRequired{kk}, ' = vector;' ] );
            %dispDebug( vector );
            
            eval( ['pfix.', cmRequired{kk}, ' = vector;' ] );
    	end
    end
    
    COV = struct();
    
    fname = [basepath, '/', prefix , '_COV_spEvec', '.in'];
    if exist( fname, 'file' ) ~= 2 
    	disp( ['ERROR: CellModelInit - File "', fname, '"Not Found!\n'] );
        pause;
    else
    	fr = fopen(fname);
		[vector,n] = fread(fr,'double');
        fclose(fr);
    	
    	COV.spE = diag(vector);     
    end

    fname = [basepath, '/', prefix , '_COV_spRvec', '.in'];
    if exist( fname, 'file' ) ~= 2 
    	disp( ['ERROR: CellModelInit - File "', fname, '"Not Found!\n'] );
        pause;
    else
    	fr = fopen(fname);
		[vector,n] = fread(fr,'double');
        fclose(fr);
    	
    	COV.spR = diag(vector);     
    end    
    
    fname = [basepath, '/', prefix , '_COV_sxVvec', '.in'];
    if exist( fname, 'file' ) ~= 2 
    	disp( ['ERROR: CellModelInit - File "', fname, '"Not Found!\n'] );
        pause;
    else
    	fr = fopen(fname);
		[vector,n] = fread(fr,'double');
        fclose(fr);
    	
    	COV.sxV = diag(vector);     
    end
    
    fname = [basepath, '/', prefix , '_COV_sxWvec', '.in'];
    if exist( fname, 'file' ) ~= 2 
    	disp( ['ERROR: CellModelInit - File "', fname, '"Not Found!\n'] );
        pause;
    else
    	fr = fopen(fname);
		[vector,n] = fread(fr,'double');
        fclose(fr);
    	
    	COV.sxW = diag(vector);     
    end
    
    deltat = 0.0;
    fname = [basepath, '/', prefix , '_deltat', '.in'];
    if exist( fname, 'file' ) ~= 2 
    	disp( ['ERROR: CellModelInit - File "', fname, '"Not Found!\n'] );
        pause;
    else
    	fr = fopen(fname);
		[vector,n] = fread(fr,'double');
        fclose(fr);
    	
    	deltat = vector(1);     
    end
    %dispDebug( pfix ) ;
    cellmodel = eval( [cmName, '( pfix, COV, deltat );' ] );
end
    