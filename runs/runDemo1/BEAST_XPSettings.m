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

XP.Info.ModelName = BEAST.XPGen.ModelName;
XP.Info.Title     = 'EXPERIMENT';


BTfilename       = '../../datafiles/BEASTDataBT_SLB283452H';

load(BTfilename, 'BTdata');

XP.pfix          = BTdata;
XP.pfix.eta      = 1.;
XP.pfix.Qn_Ah    = 0.35;
XP.pfix.R0       = 200e-3;
XP.pfix.R1       = 86e-3;
XP.pfix.C1       = 450;
XP.pfix.R2       = 150e-3;
XP.pfix.C2       = 8.5e+3;


XP.x0(1,1) = 1;     
XP.x0(2,1) = 0.00;     
XP.p0(1,1) = 100e-3;

if strcmp(BEAST.XPGen.ModelName, 'R0A1B1' )

    XP.obj = CellModels.R0A1B1( XP.pfix, COV, XP.deltat );
    
    XP.p0(2,1) = 0.999;
    XP.p0(3,1) = -1.e-5;
    
elseif strcmp( BEAST.XPGen.ModelName, 'R0R1C1' )
    
    COV.sxW = diag([COV.xSOC COV.xVC1]);
    COV.sxV = COV.vout;
    COV.spR = diag([COV.pR0 COV.pR1 COV.pC1]);
    COV.spE = COV.vout;
    
    XP.obj = CellModels.R0R1C1( XP.pfix, COV, XP.deltat );
    
    XP.p0(2,1) = 100e-3;         % R0
    XP.p0(2,1) = 100e-3;         % R1
    XP.p0(3,1) = 50/XP.p0(2,1);  % C1
    
elseif strcmp( BEAST.XPGen.ModelName, 'R0R1T1' )


    XP.obj = CellModels.R0R1T1( XP.pfix, COV, XP.deltat );
    XP.p0(2,1) = 1.e-3;
    XP.p0(3,1) = 30*60;
    
elseif strcmp( BEAST.XPGen.ModelName, 'R0R1C1R2C2' )
    
    COV.sxW = diag([COV.xSOC COV.xVC1 COV.xVC1]);
    COV.sxV = COV.vout;
    COV.spR = diag([COV.pR0 COV.pR1 COV.pC1 COV.pR1 COV.pC1]);
    COV.spE = COV.vout;
    
    XP.obj = CellModels.R0R1C1R2C2( XP.pfix, COV, XP.deltat );
    
    
    XP.x0(2,1) = 0.00;
    XP.x0(3,1) = 0.00;
    
    XP.p0(2,1) = 100e-3;          % R0
    XP.p0(2,1) = 50e-3;           % R1
    XP.p0(3,1) = 50/XP.p0(2,1);   % C1
    XP.p0(4,1) = 50e-3;           % R2
    XP.p0(5,1) = 1500/XP.p0(4,1); % C2     
end


% Dimensional and consistency check
XP.obj.CheckCellModelDim(XP);
XP.p0 = XP.obj.CoerceParsCompatibility( XP.p0 );
XP.x0 = XP.obj.CoerceStateCompatibility( XP.x0 );