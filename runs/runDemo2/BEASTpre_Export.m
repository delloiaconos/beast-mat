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

direfileinput = [localFolder,'in/'];
extefileinput = '.in';
% Creazione della cartella ./in, se necessario
if ( exist(direfileinput, 'dir') == 0 )
    mkdir(direfileinput);
end


varname = 'MDCellModelSel';
if exist( varname, 'var' )
    fname = [direfileinput, 'MD_CellModelSel.txt'];
    fw     = fopen(fname,'wt');
    fprintf(fw,MDCellModelSel);
    fclose(fw);
    clear fw;
else
    disp( ['WARNING: Unable to Export "' varname '"'] );
end

varname = 'MDCellModelSel';
if exist( varname, 'var' )
    fname = [direfileinput, 'MD_EstimationMethodSel.txt'];
    fw     = fopen(fname,'wt');
    fprintf(fw,'%s',EstimationMethodSel);
    fclose(fw);
    clear fw
else
    disp( ['WARNING: Unable to Export "' varname '"'] );
end
    
% Esportazione MD
fname = [direfileinput, 'MD_deltat', extefileinput];
    beast.io.writeDoubleMatrix(fname, MD.deltat);
fname = [direfileinput, 'MD_t_all', extefileinput];
    beast.io.writeDoubleMatrix(fname, MD.t_all);
fname = [direfileinput, 'MD_u_all', extefileinput];        % matrice
    beast.io.writeDoubleMatrix(fname, MD.u_all);
fname = [direfileinput, 'MD_yXP_all', extefileinput];       % matrice
    beast.io.writeDoubleMatrix(fname, MD.yXP_all);
fname = [direfileinput, 'MD_x0', extefileinput];
    beast.io.writeDoubleMatrix(fname, MD.x0);
fname = [direfileinput, 'MD_p0', extefileinput];
    beast.io.writeDoubleMatrix(fname, MD.p0);

fname = [direfileinput, 'MD_COV_sxWvec', extefileinput];
    beast.io.writeDoubleMatrix(fname, diag(MDobj.sxW));
fname = [direfileinput, 'MD_COV_sxVvec', extefileinput];
    beast.io.writeDoubleMatrix(fname, diag(MDobj.sxV));
fname = [direfileinput, 'MD_COV_spRvec', extefileinput];
    beast.io.writeDoubleMatrix(fname, diag(MDobj.spR));
fname = [direfileinput, 'MD_COV_spEvec', extefileinput];
    beast.io.writeDoubleMatrix(fname, diag(MDobj.spE));
    
fname = [direfileinput, 'MD_pfix_Qn_Ah', extefileinput];
    beast.io.writeDoubleMatrix(fname, MD.pfix.Qn_Ah);
fname = [direfileinput, 'MD_pfix_eta', extefileinput];
    beast.io.writeDoubleMatrix(fname, MD.pfix.eta);
fname = [direfileinput, 'MD_pfix_soc', extefileinput];
    beast.io.writeDoubleMatrix(fname, MD.pfix.soc);
fname = [direfileinput, 'MD_pfix_ocv0', extefileinput];
    beast.io.writeDoubleMatrix(fname, MD.pfix.ocv0);
fname = [direfileinput, 'MD_pfix_ocv1', extefileinput];
    beast.io.writeDoubleMatrix(fname, MD.pfix.ocv1);
    
clear fname Nt pfixBattery ifigCounter



% Esportazione XP
fname = [direfileinput, 'XP_t_all', extefileinput];
    beast.io.writeDoubleMatrix(fname, XP.t_all);
fname = [direfileinput, 'XP_y_all', extefileinput];
    beast.io.writeDoubleMatrix(fname, XP.y_all);
fname = [direfileinput, 'XP_u_all', extefileinput];
    beast.io.writeDoubleMatrix(fname, XP.u_all);


fname = [direfileinput, 'XP_x_all', extefileinput];
    beast.io.writeDoubleMatrix(fname, XP.x_all);
    
%fname = [direfileinput, 'XP_p_all', extefileinput];