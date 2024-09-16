% -----------------------------
% Script: Closed Loop Shaping of Torque Controller
% Exercise 06 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Task:
% - Get operation point
% - Linearize at each operation point
% - Determine theta, kp and Ti for each operation point
% - Copy the output into NREL5MWDefaultParameter_FBSWE_Ex6_TPI.m
% ------------
% History:
% v01:	David Schlipf on 06-Oct-2019
% ----------------------------------

clearvars;close all;clc;

%% Design
OPs         = [11];             % [m/s]
D_d         = 0.7;              % [-]
omega_d     = 0.5;              % [rad/s]

%% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW2DOF;
SteadyStates                    = load('SteadyStatesNREL5MW_FBSWE_SLOW','v_0','Omega');                       

%% loop over operation points
nOP     = length(OPs);
kp      = NaN(1,nOP);
Ti      = NaN(1,nOP);

for iOP=1:nOP  
    
    % Get operation point
    OP          = OPs(iOP);
    Omega_OP  	= interp1(SteadyStates.v_0,SteadyStates.Omega,OP,'linear','extrap');
    v_0_OP      = OP;
    
    % Linearize at each operation point
    [A,B,C,D]   = LinearizeSLOW1DOF_TC(Omega_OP,v_0_OP,Parameter);        
    
    % Determine kp and Ti for each operation point
    kp(iOP)     = -(2.*D_d.*omega_d + A)./B(1)./C;
    Ti(iOP)     = kp(iOP)./(-omega_d.^2./B(1)./C);
end

fprintf('Parameter.VSC.kp                        = %s;\n',sprintf('%f',kp));
fprintf('Parameter.VSC.Ti                        = %s;\n',sprintf('%f',Ti));  
 