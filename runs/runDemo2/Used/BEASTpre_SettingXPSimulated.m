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

XP.name  = 'CellModel'; % CHOICE OF THE MODEL FOR EXPERIMENT
XP.title = 'EXPERIMENT';
XP.pfix  = pfixBattery;


XP.x0(1,1) = 0.90;     
XP.x0(2,1) = 0.00;     

if strcmp(XPCellModelSel, 'R0A1B1' )

    XPobj = CellModel_R0A1B1( pfixBattery, COV, XP.deltat );
    
    XP.p0(2,1) = 0.999;
    XP.p0(3,1) = -1.e-5;
    
elseif strcmp( XPCellModelSel, 'R0R1C1' )
    
    COV.sxW = diag([COV.xSOC COV.xVC1]);
    COV.sxV = COV.vout;
    COV.spR = diag([COV.pR0 COV.pR1 COV.pC1]);
    COV.spE = COV.vout;
    
    XPobj = CellModel_R0R1C1( pfixBattery, COV, XP.deltat );
    
    XP.p0(1,1) = pfixBattery.R0;   % R0
    XP.p0(2,1) = pfixBattery.R1;   % R1
    XP.p0(3,1) = pfixBattery.C1;   % C1
    
    
elseif strcmp( XPCellModelSel, 'R0R1T1' )


    XPobj = CellModel_R0R1T1( pfixBattery, COV, XP.deltat );
    XP.p0(2,1) = 1.e-3;
    XP.p0(3,1) = 30*60;
    
elseif strcmp( XPCellModelSel, 'R0R1C1R2C2' )
    
    COV.sxW = diag([COV.xSOC COV.xVC1 COV.xVC1]);
    COV.sxV = COV.vout;
    COV.spR = diag([COV.pR0 COV.pR1 COV.pC1 COV.pR1 COV.pC1]);
    COV.spE = COV.vout;
    
    XPobj = CellModel_R0R1C1R2C2( pfixBattery, COV, XP.deltat );
    
    %keyboard()
    XP.x0(2,1) = 0.00;
    XP.x0(3,1) = 0.00;
    
    XP.p0(1,1) = pfixBattery.R0;   % R0
    XP.p0(2,1) = pfixBattery.R1;   % R1
    XP.p0(3,1) = pfixBattery.C1;   % C1
    XP.p0(4,1) = pfixBattery.R2;   % R2
    XP.p0(5,1) = pfixBattery.C2;   % C2
        
end

% Dimensional and consistency check
XPobj.checkCellModelDim(XP);
XP.p0 = XPobj.coerceParameters( XP.p0 );


% GammaCheck and SIMULATION OF THE MODEL.
flowflag.testgamma  = 1*PlotData.Enable.PlotPreliminary ;
flowflag.simulation = 1;
ifigCounter         = 900;
[XP.x_all,XP.yclean_all] = TSim(XP,XPobj,flowflag,ifigCounter,PlotData.Enable.PlotPreliminary );

% checking NaN
IsNaNCheck(XP.u_all,1,'Iin XP');
IsNaNCheck(XP.x_all,1,'SOC XP');
IsNaNCheck(XP.x_all,2,'VC1 XP');
IsNaNCheck(XP.yclean_all,1,'Vout XP');




%XP.ynoise_all = diag(sqrt(COV.vout))*randn(1,XP.Nt);
XP.y_all = XP.yclean_all; %+ XP.ynoise_all;
