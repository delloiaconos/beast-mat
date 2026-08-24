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

clear; clc; close all; 


%% BEAST Path Settings 
BEAST.BasePath                = '../../' ; 
BEAST.LaunchDir               = pwd;


%% BEAST Experimet Simultor 
% Ho una corrente in ingresso e genero una tensione in uscita!
BEAST.XPSim.Run                    = false;

BEAST.XPSim.ModelInputPath         = './';
BEAST.XPSim.ModelInputFile         = 'BEAST_XPSimu_Current.bin';

BEAST.XPSim.ModelName              = 'R0R1C1';
BEAST.XPSim.ModelSettingsFile      = 'BEAST_XPSettings.m';

BEAST.XPSim.OutputPath             = './Data/';
BEAST.XPSim.OutputFileBaseName     = 'XPGen_';
BEAST.XPSim.OutputFileExt          = '.in';


%% BEAST Experimet Loader 
BEAST.XPLoad.Run                   = ~BEAST.XPSim.Run;


%% BEAST Model Generator
% Ho l'ingresso e l'uscita di un modello (oppure dati proventienti da
% un esperimento reale) 
BEAST.MDGen.Run                    = false;

BEAST.MDGen.SignalsLoadPath        = BEAST.XPSim.OutputPath;
%BEAST.MDGen.SignalsLoadFile        = BEAST.XPSim.OutputFileName;

BEAST.MDGen.SignalsResample        = false;
BEAST.MDGen.SignalsDeltaT          = 1;

BEAST.MDGen.ModelName              = 'R0R1C1';
BEAST.MDGen.FilterName             = 'EKFDUAL';
BEAST.MDGen.ModelSettingsFile      = 'BEAST_XPSettings.m';

% Inserire in 'BEAST.MDGen.SignalProcessingFile' il nome di un eventuale
% script per l'elaborazione dei segnali di corrente e tensione. Ad esempio
% per aggiungere un offset o rumore su tensione e corrente in ingresso agli
% stadi di elaborazione.
BEAST.MDGen.SignalProcessingFile   = '';


%% BEAST ExportData Settings
BEAST.ExprotData.Run	                 = false;
BEAST.ExprotData.InputPath            = './';
BEAST.ExprotData.FileName             = '.mat';
BEAST.ExprotData.ExportMDVectors      = false;
BEAST.ExprotData.ExportMDSettings     = true;


%% BEAST ProcMat Settings
BEAST.ProcMat.Run             = false;

BEAST.ProcMat.InputPath       = './in/';
BEAST.ProcMat.LoadBinaries    = true;        % Load from binary Files ?
BEAST.ProcMat.BinInputExt     = '.in';

BEAST.ProcMat.LoadWorkspace   = false;       % Load from matlab workspace file ?
BEAST.ProcMat.InputWorkspace  = 'model.mat'; % Matlab input workspace (this file shuld be in the input path)

BEAST.ProcMat.Plot.Enable     = true;
BEAST.ProcMat.Plot.Vars       = { 'SoC' };
BEAST.ProcMat.Plot.Rate       = 1;

% If Not LoadFromBins and Not LoadWorkspace then the data will be in the current workspace
% in a struct:
BEAST.ProcMat.InputStruc      = 'MD';

BEAST.ProcMat.OutputPath      = './outmat/';        % Output Path
BEAST.ProcMat.ClearOutputPath = true;

BEAST.ProcMat.SaveWorkspace   = false; 
BEAST.ProcMat.OutputWorkspace = 'Simulation.mat';

BEAST.ProcMat.ExportBinaries  = false;
BEAST.ProcMat.BinOutputExt    = '.out' ;

BEAST.ProcMat.PreemptiveStop  = false;
BEAST.ProcMat.PreemptiveStopAt = 1*60;


%% BEAST ProcCpp Settings
BEAST.ProcCpp.Run             = false;
BEAST.ProcCpp.InputPath       = BEAST.ProcMat.InputPath;
BEAST.ProcCpp.OutputPath      = './outcpp/';

BEAST.ProcCpp.exeName         = 'BatteriesSimulator';
BEAST.ProcCpp.exePath         = [ BEAST.BasePath, 'cppfiles/bin/' ];


%% BEAST PostProc Settings
BEAST.PostProc.Run                   = true;

BEAST.PostProc.InitialCustomScript   = '';
BEAST.PostProc.FinealCustomScript    = '';

BEAST.PostProc.TimeAxisLimit         = BEAST.ProcMat.PreemptiveStop;
BEAST.PostProc.TimeAxisLimitAt       = BEAST.ProcMat.PreemptiveStopAt;

BEAST.PostProc.TimeAxisScale         = 'min'; %s, h

BEAST.PostProc.ModelPath             = BEAST.ProcMat.InputPath;

BEAST.PostProc.MATEnable             = true;
BEAST.PostProc.MATPath               = BEAST.ProcMat.OutputPath;
BEAST.PostProc.MATImportBin          = false;

BEAST.PostProc.MATImportWS           = true;
BEAST.PostProc.MATImportWSname       = BEAST.ProcMat.OutputWorkspace;

BEAST.PostProc.CPPEnable             = false;
BEAST.PostProc.CPPPath               = BEAST.ProcCpp.OutputPath;

BEAST.PostProc.ErrorEnable           = false;

BEAST.PostProc.Docked                = true;
BEAST.PostProc.EnableSave            = false;
BEAST.PostProc.OutputPath            = './figures/';

BEAST.PostProc.SaveAsJpg             = false;
BEAST.PostProc.SaveAsEps             = false;
BEAST.PostProc.SaveAsFig             = false;

BEAST.PostProc.CloseFigs             = false;


%% BEAST Backup
BEAST.Backup.Run                     = false;
BEAST.Backup.ExternalCommand         = '../bckfigures.sh ./figures ../backups/ B00T';


%% RUN FROM HERE %%     
run( [BEAST.BasePath, 'src/BEAST_Launcher'] );