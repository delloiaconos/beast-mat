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

disp( 'BEGIN: BEAST 04 - Post Processing...' );

close all;

BinaryExt = '.in';
InputPath = BEAST.PostProc.ModelPath;

fname = [InputPath, 'MD_t_all', BinaryExt];
	MD.t_all = beast.io.readDoubleVector( fname );
    MD.Nt    = length( MD.t_all );

fname = [InputPath, 'MD_u_all', BinaryExt];        % matrice
    MD.u_all =  beast.io.readDoubleMatrix( fname, [-1, MD.Nt] );	

fname = [InputPath, 'MD_yXP_all', BinaryExt];       % matrice
    MD.yXP_all = beast.io.readDoubleMatrix( fname, [-1, MD.Nt] );

fname = [InputPath, 'XP_t_all', BinaryExt];
	XP.t_all = beast.io.readDoubleVector( fname );
    XP.Nt    = length( XP.t_all );
    
fname = [InputPath, 'XP_x_all', BinaryExt];       % matrice
    XP.x_all = beast.io.readDoubleMatrix( fname, [-1, XP.Nt] );

    
BinaryExt = '.out';

if( BEAST.PostProc.MATEnable == true  && BEAST.PostProc.MATImportBin == true )
    SimPath = BEAST.PostProc.MATPath;
    
    fname = [SimPath, 't_all', BinaryExt];       % matrice
        MAT.t_all = beast.io.readDoubleVector( fname );
        MAT.Nt    = length( MAT.t_all );
    
    fname = [SimPath, 'y_all', BinaryExt];       % matrice
        MAT.y_all = beast.io.readDoubleMatrix( fname, [-1, MAT.Nt] );
    
    fname = [SimPath, 'u_all', BinaryExt];       % matrice
        MAT.y_all = beast.io.readDoubleMatrix( fname, [-1, MAT.Nt] );
        
    fname = [SimPath, 'xP_all', BinaryExt];       % matrice
        MAT.xP_all = beast.io.readDoubleMatrix( fname, [-1, MAT.Nt] );

    fname = [SimPath, 'pP_all', BinaryExt];       % matrice
        MAT.pP_all = beast.io.readDoubleMatrix( fname, [-1, MAT.Nt] );

    fname = [SimPath, 'Lp_all', BinaryExt];       % matrice
        MAT.Lp_all = beast.io.readDoubleMatrix( fname, [-1, MAT.Nt] );

    fname = [SimPath, 'Lx_all', BinaryExt];       % matrice
        MAT.Lx_all = beast.io.readDoubleMatrix( fname, [-1, MAT.Nt] );
    
    fname = [SimPath, 'spP_all', BinaryExt];       % matrice
        MAT.spP_all = beast.io.readDoubleMatrix( fname, [-1, MAT.Nt] );
    
    fname = [SimPath, 'sxP_all', BinaryExt];       % matrice
        MAT.sxP_all = beast.io.readDoubleMatrix( fname, [-1, MAT.Nt] );
        
    fname = [SimPath, 'dy_all', BinaryExt];       % matrice
        MAT.dy_all = beast.io.readDoubleMatrix( fname, [-1, MAT.Nt] );
        
        
elseif ( BEAST.PostProc.MATEnable == true  && BEAST.PostProc.MATImportWS == true )
    WSname = [BEAST.PostProc.MATPath BEAST.PostProc.MATImportWSname ];
    load( WSname, 'MAT' );
    clear WSname;
else
    disp( 'MAT not loaded!' );
end

if( BEAST.PostProc.CPPEnable == true )
    SimPath = BEAST.PostProc.CPPPath;

    fname = [SimPath, 'xP_all', BinaryExt];       % matrice
        CPP.xP_all = beast.io.readDoubleMatrix( fname, [-1, npoints] );

    fname = [SimPath, 'pP_all', BinaryExt];       % matrice
        CPP.pP_all = beast.io.readDoubleMatrix( fname, [-1, npoints] );

    fname = [SimPath, 'Lp_all', BinaryExt];       % matrice
        CPP.Lp_all = beast.io.readDoubleMatrix( fname, [-1, npoints] );

    fname = [SimPath, 'Lx_all', BinaryExt];       % matrice
        CPP.Lx_all = beast.io.readDoubleMatrix( fname, [-1, npoints] );
end
clear SimPath ;


PlotCnf.TimeScaleDiv = 60;
PlotCnf.TimeLabel    = 'Time [min]';

if( strcmpi( 'h', BEAST.PostProc.TimeAxisScale ) == true )
    PlotCnf.TimeScaleDiv = 60*60;
    PlotCnf.TimeLabel    = 'Time [h]';
elseif( strcmpi( 'min', BEAST.PostProc.TimeAxisScale ) == true )
    PlotCnf.TimeScaleDiv = 60;
    PlotCnf.TimeLabel    = 'Time [min]';
elseif( strcmpi( 's', BEAST.PostProc.TimeAxisScale ) == true )
    PlotCnf.TimeScaleDiv = 1;
    PlotCnf.TimeLabel    = 'Time [s]';
else
    PlotCnf.TimeScaleDiv = 1;
    PlotCnf.TimeLabel    = 'Time [s]';
end


PlotCnf.xLimits = [0 max(MAT.t_all)/PlotCnf.TimeScaleDiv];
if( BEAST.PostProc.TimeAxisLimit == true )
    if( BEAST.PostProc.TimeAxisLimitAt < max(MAT.t_all) )
        PlotCnf.xLimits = [0 BEAST.PostProc.TimeAxisLimitAt/PlotCnf.TimeScaleDiv];
    end
end

PlotCnf.FontName = 'Helvetica';
PlotCnf.FontSize = 12;
PlotCnf.LblFontSize = PlotCnf.FontSize;

PlotCnf.MdlColor  = 'black';
PlotCnf.MATColor = 'blue';
PlotCnf.CppColor = 'red';
PlotCnf.LineWidth = 2;

if BEAST.PostProc.Docked == true
    set(0,'DefaultFigureWindowStyle','docked');
else
    set(0,'DefaultFigureWindowStyle','normal'); %'normal'
end

Figs = [];

%% Initial Custom Script
ScriptName = BEAST.PostProc.InitialCustomScript;
if( ~isempty( ScriptName ) && exist( [BEAST.LaunchDir, ScriptName], 'file' ) )
    run( [BEAST.LaunchDir, ScriptName]  );
else
    dispWarning( ['Unable to Execute "', ScriptName, '"!' ] );
end
clear ScriptName;

%% Model Input Vectors
figName     = 'ModelInput';
figTitle    = 'Model Input Vectors';

    disp( ['-> Plotting: "', figTitle, '"'] );
    fig = figure( 'Name', figName, 'NumberTitle', 'off' );
    hh  = gca;
    set( hh,   'FontName', PlotCnf.FontName, ...
               'FontSize', PlotCnf.FontSize );

    subplot( 2,1, 1 );
        plot( MD.t_all/PlotCnf.TimeScaleDiv, MD.yXP_all, ... 
                    'DisplayName'  , 'Matlab', ...
                    'Color'        , PlotCnf.MdlColor, ...
                    'LineWidth'    , PlotCnf.LineWidth );
        
        xlim( PlotCnf.xLimits );
        xlabel( PlotCnf.TimeLabel, 'FontSize', PlotCnf.LblFontSize );
        ylabel( 'Voltage [V]', 'FontSize', PlotCnf.LblFontSize );
        
    subplot( 2,1, 2 );
        plot( MD.t_all/PlotCnf.TimeScaleDiv, MD.u_all,  ... 
                    'DisplayName'  , 'Matlab', ...
                    'Color'        , PlotCnf.MdlColor, ...
                    'LineWidth'    , PlotCnf.LineWidth );
                
        xlim( PlotCnf.xLimits );
        xlabel( PlotCnf.TimeLabel, 'FontSize', PlotCnf.LblFontSize );
        ylabel( 'Current [A]', 'FontSize', PlotCnf.LblFontSize );
    
    title( figTitle, 'FontSize', PlotCnf.FontSize );
    %ll = legend('show', 'Location', 'best' );
    %set( ll, 'FontSize'   , PlotCnf.FontSize );       
    
    Figs(end+1) = fig;

%% Reference SoC
figName     = 'ReferenceSoC';
figTitle    = 'Reference SoC';

    disp( ['-> Plotting: "', figTitle, '"'] );
    fig = figure( 'Name', figName, 'NumberTitle', 'off' );
    hh  = gca;
    set( hh,   'FontName', PlotCnf.FontName, ...
               'FontSize', PlotCnf.FontSize );

        plot( XP.t_all/PlotCnf.TimeScaleDiv, XP.x_all(1,:), ... 
                    'DisplayName'  , 'Matlab', ...
                    'Color'        , PlotCnf.MdlColor, ...
                    'LineWidth'    , PlotCnf.LineWidth );
                
    xlim( PlotCnf.xLimits );
    xlabel( PlotCnf.TimeLabel, 'FontSize', PlotCnf.LblFontSize );
    ylabel( 'SoC', 'FontSize', PlotCnf.LblFontSize );
            
    title( figTitle, 'FontSize', PlotCnf.FontSize );
    %ll = legend('show', 'Location', 'best' );
    %set( ll, 'FontSize'   , PlotCnf.FontSize );       
    
    Figs(end+1) = fig;

%% State 1 SoC
figName     = 'SoC';
figTitle    = 'State of Charge';

    disp( ['-> Plotting: "', figTitle, '"'] );
    fig = figure( 'Name', figName, 'NumberTitle', 'off' );
    hh  = gca;
    set( hh,   'FontName', PlotCnf.FontName, ...
               'FontSize', PlotCnf.FontSize );
    
    %subplot( 2,1, 1 );
        if( BEAST.PostProc.MATEnable == true )
            plot( MAT.t_all/PlotCnf.TimeScaleDiv, MAT.xP_all(1,:), ... 
                    'DisplayName'  , 'Matlab', ...
                    'Color'        , PlotCnf.MATColor, ...
                    'LineWidth'    , PlotCnf.LineWidth );
            hold on;
            
            plot( XP.t_all/PlotCnf.TimeScaleDiv, XP.x_all(1,:), ...
                    'DisplayName'  , 'Reference', ...
                    'Color'        , 'k', ...
                    'LineWidth'    , PlotCnf.LineWidth );
        end
        
        if( BEAST.PostProc.CPPEnable == true )
            plot( MAT.t_all/PlotCnf.TimeScaleDiv, CPP.xP_all(1,:), ... 
                    'DisplayName'  , 'Cpp', ...
                    'Color'        , PlotCnf.CppColor, ...
                    'LineWidth'    , PlotCnf.LineWidth );    
        end
        
        xlim( PlotCnf.xLimits );
        xlabel( PlotCnf.TimeLabel, 'FontSize', PlotCnf.LblFontSize );
        ylabel( 'SoC', 'FontSize', PlotCnf.LblFontSize );
        title( 'SoC', 'FontSize', PlotCnf.FontSize );
        
        ll = legend('show', 'Location', 'best' );
        set( ll, 'FontSize'   , PlotCnf.FontSize );       
        
    
    Figs(end+1) = fig;

%% dy_all
figName     = 'Innovation';
figTitle    = 'Innovation';

    disp( ['-> Plotting: "', figTitle, '"'] );
    fig = figure( 'Name', figName, 'NumberTitle', 'off' );
    hh  = gca;
    set( hh,   'FontName', PlotCnf.FontName, ...
               'FontSize', PlotCnf.FontSize );

    if( BEAST.PostProc.MATEnable == true )
        plot( MAT.t_all/PlotCnf.TimeScaleDiv, MAT.dy_all, ... 
                'DisplayName'  , 'Matlab', ...
                'Color'        , PlotCnf.MATColor, ...
                'LineWidth'    , PlotCnf.LineWidth );
        hold on;

    end

    if( BEAST.PostProc.CPPEnable == true )
        plot( MAT.t_all/PlotCnf.TimeScaleDiv, CPP.dy_all(1,:), ... 
                'DisplayName'  , 'Cpp', ...
                'Color'        , PlotCnf.CppColor, ...
                'LineWidth'    , PlotCnf.LineWidth );    
    end

    xlim( PlotCnf.xLimits );
    xlabel( PlotCnf.TimeLabel, 'FontSize', PlotCnf.LblFontSize );
    ylabel( 'Innovation', 'FontSize', PlotCnf.LblFontSize );
    title( 'Innovation', 'FontSize', PlotCnf.FontSize );

    ll = legend('show', 'Location', 'best' );
    set( ll, 'FontSize'   , PlotCnf.FontSize );      
    
    Figs(end+1) = fig;
    

if( BEAST.PostProc.ErrorEnable == true && ...
    BEAST.PostProc.MATEnable == true && ... 
    BEAST.PostProc.CPPEnable == true )
    
    %% State 1 SoC
    figName     = 'SoCerror';
    figTitle    = 'SoC Error Matlab vs Cpp';

    disp( ['-> Plotting: "', figTitle, '"'] );
    fig = figure( 'Name', figName, 'NumberTitle', 'off' );
    hh  = gca;
    set( hh,   'FontName', PlotCnf.FontName, ...
               'FontSize', PlotCnf.FontSize );
    
	error = abs( MAT.xP_all(1,:) - CPP.xP_all(1,:) );
    semilogy( MAT.t_all/PlotCnf.TimeScaleDiv, error, ...
        'DisplayName'  , 'Error', ...
        'Color'        , 'green', ...
        'LineWidth'    , PlotCnf.LineWidth );
    
     xlim( PlotCnf.xLimits );
     xlabel( PlotCnf.TimeLabel, 'FontSize', PlotCnf.LblFontSize );
     ylabel( 'SoC Error', 'FontSize', PlotCnf.LblFontSize );
     title( 'SoC', 'FontSize', PlotCnf.FontSize );
        
    Figs(end+1) = fig;
end
    

%% State 1 SoC
% TODO: Indipendenza Cpp
% nstates = max( [ size(MAT.xP_all, 1) size(CPP.xP_all, 1) ] );
nstates = max( [ size(MAT.xP_all, 1) ] );

figName     = 'States';
figTitle    = 'All States';

    disp( ['-> Plotting: "', figTitle, '"'] );
    fig = figure( 'Name', figName, 'NumberTitle', 'off' );
    hh  = gca;
    set( hh,   'FontName', PlotCnf.FontName, ...
               'FontSize', PlotCnf.FontSize );
    
    for kk=2:nstates
        subplot( nstates-1, 1, kk-1 );
        
        if( kk <= size(MAT.xP_all, 1) )
            plot( MAT.t_all/PlotCnf.TimeScaleDiv, MAT.xP_all(kk,:), ...
                    'DisplayName'  , 'Matlab', ...
                    'Color'        , PlotCnf.MATColor, ...
                    'LineWidth'    , PlotCnf.LineWidth  );
            hold on;
        end
%         TODO: Indipendenza Cpp  
%         if( kk <= size(CPP.xP_all, 1) )
%             plot( MAT.t_all/PlotCnf.TimeScaleDiv, CPP.xP_all(kk,:), ...
%                     'DisplayName'  , 'Cpp', ...
%                     'Color'        , PlotCnf.CppColor, ...
%                     'LineWidth'    , PlotCnf.LineWidth  );
%         end
        
        xlim( PlotCnf.xLimits );
        ylabel( [' State #', num2str( kk-1) ] );
        xlabel( PlotCnf.TimeLabel );
    end

    Figs(end+1) = fig;
    
%% Parameters
% TODO: Indipendenza Cpp
% npars = max( [ size(MAT.pP_all, 1) size(CPP.pP_all, 1) ] );
npars = max( [ size(MAT.pP_all, 1) ] );

figName     = 'Parameters';
figTitle    = 'All Parameters';

    disp( ['-> Plotting: "', figTitle, '"'] );
    fig = figure( 'Name', figName, 'NumberTitle', 'off' );
    hh  = gca;
    set( hh,   'FontName', PlotCnf.FontName, ...
               'FontSize', PlotCnf.FontSize );
    
    for kk=1:npars
        subplot( npars, 1, kk );
        
        if( kk <= size(MAT.pP_all, 1) )
            plot( MAT.t_all/PlotCnf.TimeScaleDiv, MAT.pP_all(kk,:), ...
                    'DisplayName'  , 'Matlab', ...
                    'Color'        , PlotCnf.MATColor, ...
                    'LineWidth'    , PlotCnf.LineWidth  );
            hold on;
        end
%         TODO: Indipendenza Cpp  
%         if( kk <= size(CPP.xP_all, 1) )
%             plot( MAT.t_all/PlotCnf.TimeScaleDiv, CPP.xP_all(kk,:), ...
%                     'DisplayName'  , 'Cpp', ...
%                     'Color'        , PlotCnf.CppColor, ...
%                     'LineWidth'    , PlotCnf.LineWidth  );
%         end
        
        xlim( PlotCnf.xLimits );
        ylabel( [' Parameter #', num2str( kk-1) ] );
        xlabel( PlotCnf.TimeLabel );
    end

    Figs(end+1) = fig;

%% States Covariance
% TODO: Indipendenza Cpp
% npars = max( [ size(MAT.pP_all, 1) size(CPP.pP_all, 1) ] );
nplot = max( [ size(MAT.sxP_all  , 1) ] );

figName     = 'State Covariance';
figTitle    = 'All State Covariance';

    disp( ['-> Plotting: "', figTitle, '"'] );
    fig = figure( 'Name', figName, 'NumberTitle', 'off' );
    hh  = gca;
    set( hh,   'FontName', PlotCnf.FontName, ...
               'FontSize', PlotCnf.FontSize );
    
    for kk=1:nplot
        subplot( nplot, 1, kk );
        
        if( kk <= size(MAT.sxP_all, 1) )
            plot( MAT.t_all/PlotCnf.TimeScaleDiv, MAT.sxP_all(kk,:), ...
                    'DisplayName'  , 'Matlab', ...
                    'Color'        , PlotCnf.MATColor, ...
                    'LineWidth'    , PlotCnf.LineWidth  );
            hold on;
        end
        
        xlim( PlotCnf.xLimits );
        ylabel( ['Cov for State #', num2str( kk-1) ] );
        xlabel( PlotCnf.TimeLabel );
    end

    Figs(end+1) = fig;


%% Parameters Covariance
% TODO: Indipendenza Cpp
% npars = max( [ size(MAT.pP_all, 1) size(CPP.pP_all, 1) ] );
nplot = max( [ size(MAT.spP_all  , 1) ] );

figName     = 'Parameters Covariance';
figTitle    = 'All Parameters Covariance';

    disp( ['-> Plotting: "', figTitle, '"'] );
    fig = figure( 'Name', figName, 'NumberTitle', 'off' );
    hh  = gca;
    set( hh,   'FontName', PlotCnf.FontName, ...
               'FontSize', PlotCnf.FontSize );
    
    for kk=1:nplot
        subplot( nplot, 1, kk );
        
        if( kk <= size(MAT.spP_all, 1) )
            plot( MAT.t_all/PlotCnf.TimeScaleDiv, MAT.spP_all(kk,:), ...
                    'DisplayName'  , 'Matlab', ...
                    'Color'        , PlotCnf.MATColor, ...
                    'LineWidth'    , PlotCnf.LineWidth  );
            hold on;
        end
        
        xlim( PlotCnf.xLimits );
        ylabel( ['Cov for Parameter #', num2str( kk-1) ] );
        xlabel( PlotCnf.TimeLabel );
    end

    Figs(end+1) = fig;  


%% State And Covariance Figures
% TODO: Indipendenza Cpp
% npars = max( [ size(MAT.pP_all, 1) size(CPP.pP_all, 1) ] );
nstates = max( [ size(MAT.xP_all, 1) ] );

for kk=1:nstates
    figName     = ['StateN' num2str(kk-1) ];
    figTitle    = ['State # ' num2str(kk-1)];

        disp( ['-> Plotting: "', figTitle, '"'] );
        fig = figure( 'Name', figName, 'NumberTitle', 'off' );
        hh  = gca;
        set( hh,   'FontName', PlotCnf.FontName, ...
                   'FontSize', PlotCnf.FontSize );
        
        subplot( 2,1,1 );
            plot( MAT.t_all/PlotCnf.TimeScaleDiv, MAT.xP_all(kk,:), ...
                        'DisplayName'  , 'Matlab', ...
                        'Color'        , PlotCnf.MATColor, ...
                        'LineWidth'    , PlotCnf.LineWidth  );
            xlim( PlotCnf.xLimits );
            ylabel( ['State #', num2str(kk-1) ] );
            xlabel( PlotCnf.TimeLabel );

        subplot( 2,1,2 );        
            semilogy( MAT.t_all/PlotCnf.TimeScaleDiv, abs(MAT.sxP_all(kk,:)), ...
                        'DisplayName'  , 'Matlab', ...
                        'Color'        , PlotCnf.MATColor, ...
                        'LineWidth'    , PlotCnf.LineWidth  );
            
            xlim( PlotCnf.xLimits );
            xlabel( PlotCnf.TimeLabel );
            ylabel( 'Covariance' );
            
        Figs(end+1) = fig; 
end


%% Parameter And Covariance Figures
% TODO: Indipendenza Cpp
% npars = max( [ size(MAT.pP_all, 1) size(CPP.pP_all, 1) ] );
npars = max( [ size(MAT.pP_all  , 1) ] );

for kk=1:npars
    figName     = ['ParameterN' num2str(kk-1) ];
    figTitle    = ['Parameter # ' num2str(kk-1)];

        disp( ['-> Plotting: "', figTitle, '"'] );
        fig = figure( 'Name', figName, 'NumberTitle', 'off' );
        hh  = gca;
        set( hh,   'FontName', PlotCnf.FontName, ...
                   'FontSize', PlotCnf.FontSize );
        
        subplot( 2,1,1 );
            plot( MAT.t_all/PlotCnf.TimeScaleDiv, MAT.pP_all(kk,:), ...
                        'DisplayName'  , 'Matlab', ...
                        'Color'        , PlotCnf.MATColor, ...
                        'LineWidth'    , PlotCnf.LineWidth  );
            ylabel( ['Parameter #', num2str(kk-1) ] );
            xlabel( PlotCnf.TimeLabel );
            xlim( PlotCnf.xLimits );
            
        subplot( 2,1,2 );        
            semilogy( MAT.t_all/PlotCnf.TimeScaleDiv, abs(MAT.spP_all(kk,:)), ...
                        'DisplayName'  , 'Matlab', ...
                        'Color'        , PlotCnf.MATColor, ...
                        'LineWidth'    , PlotCnf.LineWidth  );
            
            xlim( PlotCnf.xLimits );
            xlabel( PlotCnf.TimeLabel );
            ylabel( 'Covariance' );

        Figs(end+1) = fig; 
end

clear fig figName figTitle ll hh;
clear npars nstates nplot;

%% Final Custom Script
ScriptName = BEAST.PostProc.FinalCustomScript;
if( ~isempty( ScriptName ) && exist( [BEAST.LaunchDir, ScriptName], 'file' ) )
    run( [BEAST.LaunchDir, ScriptName]  );
else
    dispWarning( ['Unable to Execute "', ScriptName, '"!' ] );
end
clear ScriptName;

clear PlotCnf;

%%
%% Saving Figs
clear MAT CPP MD XP;
OutputPath = BEAST.PostProc.OutputPath;
if( exist( OutputPath,'dir') == 0 )
    mkdir( OutputPath );
end

for kk=1:length(Figs)
    figH      = Figs(kk);
    figName   = get( figH , 'Name' );
    figPath   = strcat( OutputPath, figName);

    fprintf( 'Saving: %s...\n', figName );

    if(  BEAST.PostProc.SaveAsJpg == true )
        saveas( figH, figPath, 'jpg' );
    end

    if(  BEAST.PostProc.SaveAsEps == true )
        saveas( figH, figPath, 'epsc' );
    end

    if(  BEAST.PostProc.SaveAsFig == true )
        saveas( figH, figPath, 'fig' );
    end

    if(  BEAST.PostProc.CloseFigs )
        close( figH );
    end
end
clear Figs figH figName figPath kk OutputPath;


disp( 'END: BEAST 04 - Post Processing...' );

