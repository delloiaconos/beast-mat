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

%% CHOICE OF THE MODEL

%MDobj = CellModel_H0F0A( pfixBattery, COV, MD.deltat  );


% Preparazione delle matrici di covarianza
COV.sxW = diag([COV.xSOC COV.xVC1]);
COV.sxV = COV.vout;
COV.spR = diag([COV.pR0 COV.pR1 COV.pC1]);
COV.spE = COV.vout;

%MD.x0(1,1) = 0.5*XP.x0(1,1);     
%MD.x0(2,1) = XP.x0(2,1);     
%MD.p0(1,1) = XP.p0(1,1);    

if strcmp(MDCellModelSel, 'R0A1B1' )
    
    
    MDobj = CellModel_R0A1B1( pfixBattery, COV, MD.deltat );
    
    MD.p0(1,1) = XP.p0(1,1);    
    MD.p0(2,1) = 0.5*XP.p0(2,1);
    MD.p0(3,1) = XP.p0(3,1);
    
elseif strcmp( MDCellModelSel, 'R0R1C1' )
    
    COV.sxW = diag([COV.xSOC COV.xVC1]);
    COV.sxV = COV.vout;
    COV.spR = diag([COV.pR0 COV.pR1 COV.pC1]);
    COV.spE = COV.vout;

    MDobj = CellModel_R0R1C1( pfixBattery, COV, MD.deltat );
    
    MD.x0(1,1) = 0.7*XP.x0(1,1);     
    MD.x0(2,1) = XP.x0(2,1);     
    
    MD.p0(1,1) = 0.7*XP.p0(1,1);    
    MD.p0(2,1) = XP.p0(2,1);
    MD.p0(3,1) = XP.p0(3,1);

elseif strcmp( MDCellModelSel, 'R0R1T1' )
    
    MDobj = CellModel_R0R1T1( pfixBattery, COV, MD.deltat );
    
    MD.p0(1,1) = XP.p0(1,1);    
    MD.p0(2,1) = 0.8*XP.p0(2,1);
    MD.p0(3,1) = 0.8*XP.p0(3,1);
    
elseif strcmp( MDCellModelSel, 'R0R1C1R2C2' )
        
    COV.sxW = diag([COV.xSOC COV.xVC1 COV.xVC1]);
    COV.sxV = COV.vout;
    COV.spR = diag([COV.pR0 COV.pR1 COV.pC1 COV.pR2 COV.pC2]);
    COV.spE = COV.vout;
    
    MDobj = CellModel_R0R1C1R2C2( pfixBattery, COV, MD.deltat );
    
    MD.x0(1,1) = 0.70*XP.x0(1,1);     
    MD.x0(2,1) = 1.00*XP.x0(2,1);     
    MD.x0(3,1) = 1.00*XP.x0(3,1);
     
    MD.p0(1,1) = 0.70*XP.p0(1,1);    
    MD.p0(2,1) = 1.70*XP.p0(2,1); 
    MD.p0(3,1) = 1.00*XP.p0(3,1);   
    MD.p0(4,1) = 1.20*XP.p0(4,1);
    MD.p0(5,1) = 1.00*XP.p0(5,1);

elseif strcmp( MDCellModelSel, 'R0R1A1R2A2' )
    
    COV.sxW = diag([COV.xSOC COV.xVC1 COV.xVC1]);
    COV.sxV = COV.vout;
    COV.spR = diag([COV.pR0 COV.pR1 COV.pA1 COV.pR2 COV.pA2]);
    COV.spE = COV.vout;
    
    MDobj = CellModel_R0R1A1R2A2( pfixBattery, COV, MD.deltat );
    
    MD.x0(1,1) = 0.80*XP.x0(1,1);     
    MD.x0(2,1) = 1.00*XP.x0(2,1);     
    MD.x0(3,1) = 1.00*XP.x0(3,1);
     
    MD.p0(1,1) = 1.00*XP.p0(1,1);    
    MD.p0(2,1) = 1.00*XP.p0(2,1); 
    MD.p0(3,1) = 0.70*exp( - 0.25./(XP.p0(2,1).*XP.p0(3,1)) ); 
    MD.p0(4,1) = 1.00*XP.p0(4,1);
    MD.p0(5,1) = 1.00*exp( - 0.25./(XP.p0(4,1).*XP.p0(5,1)) );

end


if FlowFlag.DataSel.CellModelIdenticalPars==1
    MD.p0 = XP.p0;
    disp 'identical pars'
end

MD.name  = 'CellModel';
MD.title = 'MODEL';
MD.pfix = pfixBattery;

MDobj.CheckCellModelDim(MD);
MD.p0 = MDobj.CoerceParsCompatibility( MD.p0 );

    
%% GammaCheck and SIMULATION OF THE MODEL.
flowflag.simulation = 0;
flowflag.testgamma  = 1*PlotData.Enable.PlotPreliminary*flowflag.simulation;
ifigCounter         = 800;

if flowflag.simulation==1
    [MD.x_all,MD.yclean_all] = TSim(MD,MDobj,flowflag,ifigCounter,iPlotMD);
end
clear flowflag
