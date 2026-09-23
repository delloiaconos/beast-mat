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

MD.Info.ModelName = BEAST.XPGen.ModelName;
MD.Info.Title     = 'EXPERIMENT';


BTfilename       = 'BEASTDataBT_SLB283452H';
load(BTfilename, 'BTdata');

MD.pfix          = BTdata;
MD.pfix.eta      = 1.;
MD.pfix.Qn_Ah    = 0.35;
MD.pfix.R0       = 200e-3;
MD.pfix.R1       = 86e-3;
MD.pfix.C1       = 450;
MD.pfix.R2       = 150e-3;
MD.pfix.C2       = 8.5e+3;

MD.x0(1,1) = 1;     
MD.x0(2,1) = 0.00;     
MD.p0(1,1) = 100e-3;

if strcmp(BEAST.XPGen.ModelName, 'R0A1B1' )

    MD.obj = beast.CellModels.R0A1B1( MD.pfix, COV, MD.deltat );
    
    MD.p0(2,1) = 0.999;
    MD.p0(3,1) = -1.e-5;
    
elseif strcmp( BEAST.XPGen.ModelName, 'R0R1C1' )
    
    COV.sxW = diag([COV.xSOC COV.xVC1]);
    COV.sxV = COV.vout;
    COV.spR = diag([COV.pR0 COV.pR1 COV.pC1]);
    COV.spE = COV.vout;
    
    MD.obj = beast.CellModels.R0R1C1( MD.pfix, COV, MD.deltat );
    
    MD.p0(2,1) = 100e-3;         % R0
    MD.p0(2,1) = 100e-3;         % R1
    MD.p0(3,1) = 50/MD.p0(2,1);  % C1
    
elseif strcmp( BEAST.XPGen.ModelName, 'R0R1T1' )


    MD.obj = beast.CellModels.R0R1T1( MD.pfix, COV, MD.deltat );
    MD.p0(2,1) = 1.e-3;
    MD.p0(3,1) = 30*60;
    
elseif strcmp( BEAST.XPGen.ModelName, 'R0R1C1R2C2' )
    
    COV.sxW = diag([COV.xSOC COV.xVC1 COV.xVC1]);
    COV.sxV = COV.vout;
    COV.spR = diag([COV.pR0 COV.pR1 COV.pC1 COV.pR1 COV.pC1]);
    COV.spE = COV.vout;
    
    MD.obj = beast.CellModels.R0R1C1R2C2( MD.pfix, COV, MD.deltat );
    
    
    MD.x0(2,1) = 0.00;
    MD.x0(3,1) = 0.00;
    
    MD.p0(2,1) = 100e-3;          % R0
    MD.p0(2,1) = 50e-3;           % R1
    MD.p0(3,1) = 50/MD.p0(2,1);   % C1
    MD.p0(4,1) = 50e-3;           % R2
    MD.p0(5,1) = 1500/MD.p0(4,1); % C2     
end


% Dimensional and consistency check
MD.obj.checkCellModelDim(XP);
MD.p0 = MD.obj.coerceParameters( MD.p0 );
MD.x0 = MD.obj.coerceState( MD.x0 );
