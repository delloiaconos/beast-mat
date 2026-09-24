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

if fieldexists( 'BEAST', 'ProcMat' ) == false
    dispError( "BEAST_ProcMat - Unable to run widout BEAST.ProcMat!" );
	pause();
end

%%
%  ====================================
%  ============ IMPORT DATA ===========
%  ====================================
%
if BEAST.ProcMat.LoadBinaries == true
    run( 'BEAST_ProcMat_LoadBinaries' );
else
	dispError( "BEAST_ProcMat - Import from Binaries ONLY!" );
	pause();
end
    
%%
%  ====================================
%  ========= FILTER SELECTION =========
%  ====================================
%
pckName    = 'beast.Estimators';
pckContent = what( pckName );
pckClasses = pckContent.classes;

for ii=1:length( pckClasses )
    if strcmpi( MD.EstimationMethodSel, pckClasses{ii} ) == true
        className = sprintf( '%s.%s', pckName, pckClasses{ii} );
        strEval = sprintf( 'objEstimator = %s( MDobj, MD.deltat );', className );
        eval( strEval );
        
        if( exist( 'objEstimator', 'var' ) == false || isa( objEstimator, className ) == false )
            dispError( 'BEAST_ProcMat - Problem found in istancing the class' );
            break; 
        else
            dispInfo( "Class '%s' Instancied!", className );
        end
        clear className strEval;
        
        break;
    end
end
clear pckName pckContent pckClasses ii;

if( exist( 'objEstimator', 'var' ) == false )
    dispError( "BEAST_ProcMat - Unrecognized filter: '%s'!", MD.EstimationMethodSel );
    pause();
end

MAT.FilterName = objEstimator.FilterName;

% PreemptiveStop 
kkStop = MD.Nt;
if( BEAST.ProcMat.PreemptiveStop == true )
    kkStop = find( MD.t_all <= BEAST.ProcMat.PreemptiveStopAt, 1, 'last' );
    if( kkStop > MD.Nt )
        kkStop = MD.Nt;
    end
end

dispInfo( "STARTING FILTER: '%s'.", MAT.FilterName );

objMembers = properties( objEstimator );


% Creat here my export list...
ExportableVars = cell( 1, 1 );
ExportList     = {};

for jj = 1:length( objEstimator.ExportableVars )
    
    Var = cell2struct( objEstimator.ExportableVars{jj}, ...
                       beast.Estimators.Estimator.ExportableVarsFields, 2 );
    iiFunHandler = find( strcmpi(beast.Estimators.Estimator.ExportableVarsFields, 'FunHandler' ) );
    
    ExportableVars{jj} = Var.ExportName;
    
    if any( ismember( objMembers, Var.ClassVar ) )
        if( ~isempty( Var.FunHandler ) && isa( Var.FunHandler, 'function_handle') )
            strExport = sprintf( 'objEstimator.ExportableVars{%d}{%d}( objEstimator.%s )', jj, iiFunHandler, Var.ClassVar );
        else
            strExport = sprintf( 'objEstimator.%s', Var.ClassVar );
        end
        
        % Export only if ExportName is not null and Export == TRUE
        if( ~isempty( Var.ExportName ) && Var.Export == true)
            
            strExport = sprintf( 'MAT.%s(:,kk) = %s;', Var.ExportName, strExport );
            
            ExportList{end+1} = strExport;
        
            % vector collecting results
            strSize = Var.Size;
            strSize = strrep( strSize, 'Nx', 'objEstimator.Nx' );
            strSize = strrep( strSize, 'Ny', 'objEstimator.Ny' );
            strSize = strrep( strSize, 'Np', 'objEstimator.Np' );
            strSize = strrep( strSize, 'Nu', 'objEstimator.Nu' );
            strCreate = sprintf( 'MAT.%s = zeros( %s, kkStop );', Var.ExportName, strSize );
            eval( strCreate );
        end
    else
        dispError( "BEAST_ProcMat - Unable to export: '%s'.", Var.ClassVar );
    end
end
clear strExport strCreate strSize Var iiFunHandler;

% Check for runtime plots 
if( BEAST.ProcMat.Plot.Enable == true )
    
    PlotList = {};
    
    rtPlots.vars.t_all = zeros( 1, 1 );
    
    for jj = 1:length( BEAST.ProcMat.Plot.Vars )
        varName = BEAST.ProcMat.Plot.Vars{jj};
        
        % Check if the variable exsists
        iVar = find( strcmpi( varName, ExportableVars ), 1, 'first' );
    
        if( ~isempty( iVar ) ) 
            
            Var = cell2struct( objEstimator.ExportableVars{iVar}, beast.Estimators.Estimator.ExportableVarsFields, 2 );
            iiFunHandler = find( strcmpi(beast.Estimators.Estimator.ExportableVarsFields, 'FunHandler' ), 1, 'first' );
           
            % vector collecting results
            strSize = Var.Size;
            strSize = strrep( strSize, 'Nx', 'objEstimator.Nx' );
            strSize = strrep( strSize, 'Ny', 'objEstimator.Ny' );
            strSize = strrep( strSize, 'Np', 'objEstimator.Np' );
            strSize = strrep( strSize, 'Nu', 'objEstimator.Nu' );
            
            if( eval( strSize ) > 1 )
                dispWarning( "BEAST_ProcMat - Unable to plot '%s', size > 1.", varName );
                pause();
            else
                strCreate = sprintf( 'rtPlots.vars.%s = zeros( 1, 1 );', varName );
                eval( strCreate );
          
                % Create the figure
                fig = figure( 'Name', ['Figure_', varName], 'NumberTitle', 'off' );
                    h = gca;
                    xpos = [MD.t_all(1), MD.t_all(kkStop)];
                    xlim( xpos );
                    ylim( [-1e-16 +1e-16] );
                    
                    ypos = get( h, 'ylim' );
                    
                    xlabel( 'Time (s)' );
                    ylabel( varName );
                    
                    xp = 3/4*(xpos(2)-xpos(1))+xpos(1);
                    yp = 1/4*(ypos(2)-ypos(1))+ypos(1);
                    t = text( xp, yp, '' );
                    set( t, 'LineStyle',  '-', 'LineWidth', 1 , 'Margin', 5, 'EdgeColor', 'black' );
                    
                    clear xpos xp ypos yp;
                    
                    title( ['Runtime Plot for "' varName '"'] );
                    
                    strCreate = sprintf( ['rtPlots.lines.%s = line( rtPlots.vars.t_all, rtPlots.vars.%s,' ...
                                              ' ''marker'', ''.'', ''markersize'', 3, ''linestyle'', ''-'' )'], ...
                                              varName, varName );
                          
                    strCreate = sprintf( '%s;rtPlots.fig.%s = h;rtPlots.text.%s = t;', strCreate, varName, varName );
                   
                eval( strCreate );
                
                if( ~isempty( Var.FunHandler ) && isa( Var.FunHandler, 'function_handle') )
                    strPlot = sprintf( 'objEstimator.ExportableVars{%d}{%d}( objEstimator.%s )', iVar, iiFunHandler, Var.ClassVar );
                else
                    strPlot = sprintf( 'objEstimator.%s', Var.ClassVar );
                end
        
                strPlot = sprintf( 'rtPlots.vars.%s(1, triop( kk == 1, 1, length( rtPlots.vars.%s ) + 1 ) ) = %s', ...
                                     varName, varName, strPlot );
                
                strPlot = sprintf( '%s;rtPlotUpdate( rtPlots.fig.%s, rtPlots.lines.%s, rtPlots.text.%s, rtPlots.vars.t_all, rtPlots.vars.%s, ''%s'' );', ...
                                    strPlot, varName, varName, varName, varName, varName );

                
                PlotList{end+1} = strPlot;
                
                clear strCreate fig  h t;
            end
            
            clear strCreate strSize strPlot Var iiFunHandler;
        else
            dispWarning( "BEAST_ProcMat - Unable to plot '%s', variable not available!", varName );
        end
    end
    clear jj varName iVar;   
end
clear ExportableVars;

%%
%  ====================================
%  ========= FILTER EXECUTION =========
%  ====================================
%

% Filter waitbar
hw = waitbar(0, MAT.FilterName );
set(findall(hw,'type','text'),'Interpreter','none');

kk = 1;
    % FILTER INIZIALIZATION
    told   = MD.t_all( kk );
    uold   = MD.u_all( kk );
    yXPold = MD.yXP_all( kk );
    x0     = MD.x0;
    p0     = MD.p0;

    objEstimator.initialize( x0, p0, uold, yXPold, told );
    
    % SAVE VARIABLES
    cellfun( @eval, ExportList );
    
    % PLOT VARIABLES
    if( BEAST.ProcMat.Plot.Enable == true )
        rtPlots.vars.t_all( kk ) = told;
        cellfun( @eval, PlotList );
    end
clear x0 p0 told uold yXPold;
 

for kk=2:kkStop
    
    % WAITBAR UPDATE
    waitbar(kk/kkStop,hw);

    % FILTER UPDATE
    tnew   = MD.t_all( kk );
    unew   = MD.u_all( kk );
    yXPnew = MD.yXP_all( kk );

    objEstimator.step( unew, yXPnew, tnew );

    % SAVE VARIABLES
    cellfun( @eval, ExportList );
    
    % PLOT VARIABLES
    if( BEAST.ProcMat.Plot.Enable == true )
        if( mod( kk, BEAST.ProcMat.Plot.Rate ) == 0 || kk == kkStop )
            rtPlots.vars.t_all( end+1 ) = tnew;
            cellfun( @eval, PlotList );
        end
    end
end
close(hw);
clear kk hw tnew unew yXPnew ExportList PlotList rtPlots;

%%
%  ====================================
%  ====== RESULTS EXPORT TO FILE ======
%  ====================================
%

dispInfo( 'BEGIN: Result Export' );

direfileoutput = BEAST.ProcMat.OutputPath;
extefileoutput = BEAST.ProcMat.BinOutputExt;

if( exist( direfileoutput, 'dir') && BEAST.ProcMat.ClearOutputPath == true )
    rmdir( direfileoutput,'s')
end

if( exist( direfileoutput, 'dir') ~= 7 )
    mkdir( direfileoutput );
end
    
% Create the MAT strucure 

MAT.Nx = objEstimator.Nx;
MAT.Ny = objEstimator.Ny;
MAT.Nu = objEstimator.Nu;
MAT.Np = objEstimator.Np;

MAT.t_all = MD.t_all(1:kkStop);
MAT.u_all = MD.u_all(1:kkStop);
MAT.y_all = MD.yXP_all(1:kkStop);

clear kkStop;


if BEAST.ProcMat.ExportBinaries == true
    for jj = 1:Nexports
        Var = objEstimator.ExportableVars{jj};

        %ExportableVars = { {"ClassVar", "Size", "ExportName", "FunctionHandlerToApply"} };
        if any( ismember( objMembers, Var{1} ) )
            fname = [direfileoutput, Var{3}, extefileoutput];
            
            strExport = sprintf( 'beast.io.writeDoubleMatrix(''%s'', MAT.%s );', fname, Var{3} );
            eval( strExport );
        else
            dispError( "BEAST_ProcMat - Unable to export: '%s'!", Var{1} );
        end
    end
    
    %Export time, input, output
    fname = [direfileoutput, 't_all', extefileoutput];
        beast.io.writeDoubleMatrix(fname, MAT.t_all );
    
    fname = [direfileoutput, 'u_all', extefileoutput];
        beast.io.writeDoubleMatrix(fname, MAT.u_all );
    
	fname = [direfileoutput, 'y_all', extefileoutput];
        beast.io.writeDoubleMatrix(fname, MAT.y_all);
end
clear jj strExport Nexports;
clear objMembers objEstimator MDobj;


if BEAST.ProcMat.SaveWorkspace == true
    save( [direfileoutput, BEAST.ProcMat.OutputWorkspace], '-mat', 'MAT' );
end
clear direfileoutput fname extefileoutput;

dispInfo( 'END: Results Export' );
