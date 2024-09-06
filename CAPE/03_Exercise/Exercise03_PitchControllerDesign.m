% -----------------------------
% Script: Designs pitch controller with closed-loop shaping.
% Exercise 03 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------

clearvars;close all;clc;

%% Design
OPs         = [12 16 20 24];    % [m/s]
D_d         = 0.7;              % [-]
omega_d     = 0.5;              % [rad/s]

%% Default Parameter Turbine and Controller (only M_g_rated and Omega_g_rated needed for LinearizeSLOW1DOF_PC)
Parameter                       = NREL5MWDefaultParameter_SLOW1DOF;
Parameter                       = NREL5MWDefaultParameter_FBNREL_PitchController(Parameter);
SteadyStates                    = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta');                       

%% loop over operation points
nOP     = length(OPs);
kp      = NaN(1,nOP);
Ti      = NaN(1,nOP);
theta   = NaN(1,nOP);

for iOP=1:nOP  
    
    % Get operation point
    v_0_OP     = OPs(iOP) ;
    theta_OP   = interp1( SteadyStates.theta, SteadyStates.v_0, v_0_OP) ;
    omega_OP   = interp1( SteadyStates.Omega, SteadyStates.v_0, v_0_OP) ;

    % Linearize at each operation point
    [A,B,C,D] = LinearizeSLOW1DOF_PC(theta_OP,Omega_OP,v_0_OP,Parameter) ;
    
    % Determine theta, kp and Ti for each operation point
    theta(iOP) = C*b(2)/(omega_d^2)          ;
    kp(iOP)    = -(2*D*omega_d + A)/(B(1)*C) ;
    Ti(iOP)    = - (omega_d^2)/(B(1)*C)      ;

end

fprintf('Parameter.CPC.GS.theta                  = [%s];\n',sprintf('%f ',theta));
fprintf('Parameter.CPC.GS.kp                     = [%s];\n',sprintf('%f ',kp));
fprintf('Parameter.CPC.GS.Ti                     = [%s];\n',sprintf('%f ',Ti));  
 
