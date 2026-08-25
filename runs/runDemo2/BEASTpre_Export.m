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
    BINexport_MATdouble(MD.deltat,fname);
fname = [direfileinput, 'MD_t_all', extefileinput];
    BINexport_MATdouble(MD.t_all,fname);
fname = [direfileinput, 'MD_u_all', extefileinput];        % matrice
    BINexport_MATdouble(MD.u_all,fname);
fname = [direfileinput, 'MD_yXP_all', extefileinput];       % matrice
    BINexport_MATdouble(MD.yXP_all,fname);
fname = [direfileinput, 'MD_x0', extefileinput];
    BINexport_MATdouble(MD.x0,fname);
fname = [direfileinput, 'MD_p0', extefileinput];
    BINexport_MATdouble(MD.p0,fname);

fname = [direfileinput, 'MD_COV_sxWvec', extefileinput];
    BINexport_MATdouble(diag(MDobj.sxW),fname);
fname = [direfileinput, 'MD_COV_sxVvec', extefileinput];
    BINexport_MATdouble(diag(MDobj.sxV),fname);
fname = [direfileinput, 'MD_COV_spRvec', extefileinput];
    BINexport_MATdouble(diag(MDobj.spR),fname);
fname = [direfileinput, 'MD_COV_spEvec', extefileinput];
    BINexport_MATdouble(diag(MDobj.spE),fname);
    
fname = [direfileinput, 'MD_pfix_Qn_Ah', extefileinput];
    BINexport_MATdouble(MD.pfix.Qn_Ah,fname);
fname = [direfileinput, 'MD_pfix_eta', extefileinput];
    BINexport_MATdouble(MD.pfix.eta,fname);
fname = [direfileinput, 'MD_pfix_soc', extefileinput];
    BINexport_MATdouble(MD.pfix.soc,fname);
fname = [direfileinput, 'MD_pfix_ocv0', extefileinput];
    BINexport_MATdouble(MD.pfix.ocv0,fname);
fname = [direfileinput, 'MD_pfix_ocv1', extefileinput];
    BINexport_MATdouble(MD.pfix.ocv1,fname);
    
clear fname Nt pfixBattery ifigCounter



% Esportazione XP
fname = [direfileinput, 'XP_t_all', extefileinput];
    BINexport_MATdouble(XP.t_all,fname);
fname = [direfileinput, 'XP_y_all', extefileinput];
    BINexport_MATdouble(XP.y_all,fname);
fname = [direfileinput, 'XP_u_all', extefileinput];
    BINexport_MATdouble(XP.u_all,fname);


fname = [direfileinput, 'XP_x_all', extefileinput];
    BINexport_MATdouble(XP.x_all, fname);
    
%fname = [direfileinput, 'XP_p_all', extefileinput];

    

