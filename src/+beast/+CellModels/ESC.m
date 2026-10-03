% BEAST - Battery Estimation Algorithms and Simulation Toolkit
%
% This file is part of the BEAST MATLAB implementation.
%
% Class: ESC
% Description: Enhanced Self-Correcting (ESC) equivalent-circuit model.

classdef ESC < beast.CellModels.CellModel
    % x(1,1) <-> SOC
    % x(2,1) <-> h (dynamic hysteresis)
    % x(3,1) <-> s (instantaneous hysteresis)
    % x(4,1) <-> vC1 (diffusion voltage)
    % y(1,1) <-> Vcell
    % p(1,1) <-> R0 
    % p(2,1) <-> R1 
    % p(3,1) <-> C1 
    % p(4,1) <-> gamma
    % p(5,1) <-> M
    % p(6,1) <-> M0

    properties(Constant)
        Nx = 4;
        Np = 6; 
        Nu = 1;
        Ny = 1;
        
        coefficients = {"Qn_Ah", "eta", "soc", "ocv0", "ocv1"};
        
        states = { "SoC", "h", "s", "Vc1" };
        parameters = { "R0", "R1", "C1", "gamma", "M", "M0" };
        Inputs = { "Icell" };
        Outputs = { "Vcell" };
    end

    properties(Constant,GetAccess=protected)
        coefficientsBound   = { ...
                            Bounds( 0.0, NaN, true, false ), ...
                            Bounds( -1.0, 1.0, false, false ), ...
                            Bounds( 0.0, 1.0, false, false ), ...
                            Bounds( NaN, NaN, false, false ), ...
                            Bounds( NaN, NaN, false, false ) ...
                        };
                            
        statesBound         = { ...
                            Bounds(0.0, 1.0, false, false), ...
                            Bounds(-1.0, 1.0, false, false), ...
                            Bounds(-1.0, 1.0, false, false), ...
                            Bounds(NaN, NaN, false, false) ...
                        };
                        
        parametersBound     = { ...
                            Bounds(0.0, NaN, true, false), ...
                            Bounds(0.0, NaN, true, false), ...
                            Bounds(0.0, NaN, true, false), ...
                            Bounds(0.0, NaN, true, false), ...
                            Bounds(0.0, NaN, true, false), ...
                            Bounds(0.0, NaN, true, false) ...
                        };
    end

    properties(Access=public)
        Qnom;
        eta;

        lutsoc;
        lutocv0;
        lutocv1;
    end

    properties(Access=private)
        CoulombCountingConstant;
    end

    methods(Access=public)

        % Constructor
        function obj = ESC( coeffs, cov, deltat )
            obj@beast.CellModels.CellModel( coeffs, cov, deltat );
            
            if( obj.checkCoefficients( coeffs ) == true )
                obj.Qnom    = coeffs.Qn_Ah*3600;
                obj.eta     = coeffs.eta;
            
                obj.lutsoc  = coeffs.soc;
                obj.lutocv0 = coeffs.ocv0;
                obj.lutocv1 = coeffs.ocv1;
                
                obj.CoulombCountingConstant = obj.eta*obj.deltatfix/obj.Qnom;
            end
            
            if( obj.checkCovariances( cov ) == true )
                obj.sxW = cov.sxW;
                obj.sxV = cov.sxV;
                obj.spR = cov.spR;
                obj.spE = cov.spE;
            end
        end

        function res = f0( obj, xold, pold, uold, deltat )
            alpha1 = exp(-obj.deltatfix / (pold(2,1) * pold(3,1)));
            A_H = exp(-abs(uold(1,1) * pold(4,1) * obj.CoulombCountingConstant));
            
            current_sign = sign(-uold(1,1));
            
            if uold(1,1) == 0.0
                s_next = xold(3,1);
                h_next = xold(2,1);
            else
                s_next = current_sign;
                h_next = A_H * xold(2,1) + (1.0 - A_H) * current_sign;
            end
            
            res = zeros(4,1);
            res(1,1) = xold(1,1) - obj.CoulombCountingConstant * uold(1,1);
            res(2,1) = h_next;
            res(3,1) = s_next;
            res(4,1) = alpha1 * xold(4,1) + pold(2,1) * (alpha1 - 1.0) * uold(1,1);
        end
            
        function res = g0( obj, xold, pold, uold, deltat )
            ocv0old  = interp1(obj.lutsoc, obj.lutocv0, xold(1,1));
            res(1,1) = ocv0old - pold(1,1) * uold(1,1) + xold(4,1) + pold(5,1) * xold(2,1) + pold(6,1) * xold(3,1);
        end
        
        function res = f1x( obj, xold, pold, uold, deltat )
            alpha1 = exp(-obj.deltatfix / (pold(2,1) * pold(3,1)));
            A_H = exp(-abs(uold(1,1) * pold(4,1) * obj.CoulombCountingConstant));
            
            if uold(1,1) == 0.0
                s_deriv = 1.0;
            else
                s_deriv = 0.0;
            end
            
            res = diag([1.0, A_H, s_deriv, alpha1]);
        end

        function res = f1p( obj, xold, pold, uold, deltat )
            tau1   = pold(2,1) * pold(3,1);
            alpha1 = exp(-obj.deltatfix / tau1);
            adtrc1 = alpha1 * obj.deltatfix / tau1;
            
            res = zeros(4, 6);
            
            % Derivative of vC1 wrt R1 and C1
            res(4,2) = adtrc1 / pold(2,1) * xold(4,1) + (alpha1 - 1.0 + adtrc1) * uold(1,1);
            res(4,3) = adtrc1 / pold(3,1) * (xold(4,1) + pold(2,1) * uold(1,1));
            
            % Derivative of h wrt gamma
            A_H = exp(-abs(uold(1,1) * pold(4,1) * obj.CoulombCountingConstant));
            dA_H_dgamma = -abs(uold(1,1) * obj.CoulombCountingConstant) * A_H;
            current_sign = sign(-uold(1,1));
            
            res(2,4) = dA_H_dgamma * xold(2,1) - dA_H_dgamma * current_sign;
        end

        function res = g1x( obj, xold, pold, uold, deltat )
            res = zeros(1, 4);
            res(1,1) = interp1(obj.lutsoc, obj.lutocv1, xold(1,1));
            res(1,2) = pold(5,1);
            res(1,3) = pold(6,1);
            res(1,4) = 1.0;
        end
        
        function res = g1p( obj, xold, pold, uold, deltat )
            res = zeros(1, 6);
            res(1,1) = -uold(1,1);
            res(1,5) = xold(2,1);
            res(1,6) = xold(3,1);
        end
        
    end
end