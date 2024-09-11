% -----------------------------
% Function: Adds parameters for NREL5MW Baseline Torque Controller.
% Exercise 02 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Input:
% - Parameter   struct of Parameters
% ------------
% Output:
% - Parameter   struct of Parameters
% ----------------------------------
function Parameter = NREL5MWDefaultParameter_FBNREL_LowNoise_Solution(Parameter)

%% FBNREL Pitch Controller
Omega_g_rated                           = rpm2radPs(12.1*97);               % [rad/s]
Parameter.CPC.Omega_g_rated             = Omega_g_rated;

%% FBNREL Torque Controller
P_el_rated                              = 5e6;                              % [W]
lambda_opt                              = 7.00;                             % [-]
theta_opt                               = 0;                                % [deg]
theta                                   = Parameter.Turbine.SS.theta;
lambda                               	= Parameter.Turbine.SS.lambda;
c_P                                     = Parameter.Turbine.SS.c_P;
c_P_opt                                 = interp2(theta,lambda,c_P,theta_opt,lambda_opt);
rho                                     = Parameter.General.rho;
R                                       = Parameter.Turbine.R;
r_GB                                    = Parameter.Turbine.r_GB;
eta_el                                  = Parameter.Generator.eta_el;
Parameter.VSC.k                         = 1/2*rho*pi*R^5*c_P_opt/lambda_opt^3/r_GB^3;  % [Nm/(rad/s)^2]
Parameter.VSC.theta_fine                = deg2rad(1);                       % [rad]      
Parameter.VSC.Mode                      = 1;                                % [1/2]             1: ISC, constant power in Region 3; 2: ISC, constant torque in Region 3 
Parameter.VSC.M_g_rated                 = P_el_rated/eta_el/Omega_g_rated;  % [Nm] 

% region limits & region parameters based on Jonkman 2009
Parameter.VSC.Omega_g_1To1_5            = rpm2radPs(670);                   % [rad/s]
Parameter.VSC.Omega_g_1_5To2            = rpm2radPs(871);                   % [rad/s]
Parameter.VSC.Omega_g_2To2_5            = rpm2radPs(1150.9);              	% [rad/s]
Parameter.VSC.Omega_g_2_5To3            = Omega_g_rated;                    % [rad/s]

% Region 1_5: M_g = a * Omega_g + b: 
% 1.Eq: 0                   = a * Omega_g_1To1_5 + b 
% 2.Eq: k*Omega_g_1_5To2^2  = a * Omega_g_1_5To2 + b
%       a                   = k * Omega_g_1_5To2^2/(Omega_g_1_5To2-Omega_g_1To1_5)
%       b                   =-a * Omega_g_1To1_5
Parameter.VSC.a_1_5                     = Parameter.VSC.k * Parameter.VSC.Omega_g_1_5To2^2/(Parameter.VSC.Omega_g_1_5To2-Parameter.VSC.Omega_g_1To1_5);
Parameter.VSC.b_1_5                     = -Parameter.VSC.a_1_5 * Parameter.VSC.Omega_g_1To1_5;

% Region 2_5: M_g = a * Omega_g + b: 
% 1.Eq: M_g_rated           = a * Omega_g_2_5To3   	+ b 
% 2.Eq: k*Omega_g_2To2_5^2  = a * Omega_g_2To2_5    + b 
%       a                   = (M_g_rated - k * Omega_g_2To2_5^2)/(Omega_g_2_5To3-Omega_g_2To2_5)
%       b                   = (M_g_rated - a * Omega_g_2_5To3)
Parameter.VSC.a_2_5                     = (Parameter.VSC.M_g_rated - Parameter.VSC.k *     Parameter.VSC.Omega_g_2To2_5^2)/(Parameter.VSC.Omega_g_2_5To3-Parameter.VSC.Omega_g_2To2_5);
Parameter.VSC.b_2_5                     = (Parameter.VSC.M_g_rated - Parameter.VSC.a_2_5 * Parameter.VSC.Omega_g_2_5To3);

end