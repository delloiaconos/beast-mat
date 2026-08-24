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

COV.iin    = 1.e-6; 
COV.vout   = 1.e-07;

%CellModelSel ='R0R1C1R2C2';

prefR0 = 200.e-3;
prefR1 = 86e-3;
prefC1 = 450;
prefA1 = exp( - 0.25/(prefR1 *prefC1 ) );

prefR2 = 150e-3;
prefC2 = 8.5e3;
prefA2 =  exp( - 0.25/(prefR2 *prefC2 ) );

prefx1 = 1.;
prefx2 = (prefR1/(prefR0+prefR1+prefR2));
prefx3 = (prefR2/(prefR0+prefR1+prefR2));


COV.xSOC   = 1.e-2*prefx1*COV.vout;
COV.xVC1   = 1.e-16*prefx2*COV.vout;
COV.xVC2   = 1.e-16*prefx3*COV.vout;

% Pars
COV.pR0    = 1.e-3*prefR0*COV.vout;

COV.pR1    = 1.e-3*prefR1*COV.vout;
COV.pC1    = 1.e-16*prefC1*COV.vout;

COV.pR2    = 1.e-4*prefR2*COV.vout;
COV.pC2    = 1.e-16*prefC2*COV.vout;

COV.pA1    = 1.e-16*prefA2*COV.vout;
COV.pA2    = 1.e-16*prefA2*COV.vout;
