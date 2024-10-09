% -----------------------------
% Script: Tests Individual Pitch Controller (IPC).
% Exercise 09 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------

clearvars;close all;clc;

%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                              	= NREL5MWDefaultParameter_SLOW3DOF;
Parameter.Turbine.R_IPC                 = 126/2*2/3;        % [m]       Rotor radius for blade-effective wind speed
Parameter                               = NREL5MWDefaultParameter_FBSWE_IPC(Parameter);

% Modification for Exercise 1, comment out Exercise 2 !!!
Parameter.PitchActuator.omega           = 2*pi*1*10;                    % [rad/s]

% Time
Parameter.Time.dt                       = 0.01;                         % [s]       simulation time step            
Parameter.Time.TMax                     = 90;                           % [s]       simulation length

% Wind
URef                                    = 20;                           % [m/s]     for Exercise 2, this should be changed to 12 !!!
Disturbance.v_0.time                    = [ 0; 90];                     % [s]       time points to change wind speed
Disturbance.v_0.signals.values          = [ 1;  1]*URef;                % [m/s]     wind speed  
Disturbance.delta_V.time             	= [ 0; 10; 15; 50; 55; 90];     % [s]       time points to change vertical shear
Disturbance.delta_V.signals.values   	= [ 0;  0;  1;  1;  0;  0]*0.05;% [1/s]     vertical shear
Disturbance.delta_H.time             	= [ 0; 30; 35; 70; 75; 90];     % [s]       time points to change horizontal shear
Disturbance.delta_H.signals.values   	= [ 0;  0; -1; -1;  0;  0]*0.05;% [1/s]     horizontal shear

% Initial Conditions from SteadyStates
SteadyStates = load('SteadyStatesNREL5MW_FBSWE_SLOW','v_0','Omega','theta','x_T','M_g');                       
Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega   ,URef,'linear','extrap');
Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta   ,URef,'linear','extrap');
Parameter.IC.x_T                = interp1(SteadyStates.v_0,SteadyStates.x_T     ,URef,'linear','extrap');
Parameter.IC.M_g                = interp1(SteadyStates.v_0,SteadyStates.M_g     ,URef,'linear','extrap');

%% Processing SLOW
sim('NREL5MW_FBSWE_SLOW3DOF_IPC.mdl')

%% PostProcessing SLOW
% -------------------------------------------------------------------------
figure('Name','Disturbance')

% plot wind speeds
subplot(211)
hold on;box on;grid on;
plot(tout,logsout.get('v_1').Values.Data)
plot(tout,logsout.get('v_2').Values.Data)
plot(tout,logsout.get('v_3').Values.Data)
plot(tout,logsout.get('d').Values.v_0.Data)
ylabel('$v$ [m/s]','Interpreter','latex')
legend( 'blade-1-effective wind speed',...
        'blade-2-effective wind speed',...
        'blade-3-effective wind speed',...
        'rotor-effective wind speed')

% plot shears
subplot(212)
hold on;box on;grid on;
plot(tout,logsout.get('d').Values.delta_V.Data)
plot(tout,logsout.get('d').Values.delta_H.Data)
ylabel('$\delta_{V/H}$ [1/s]','Interpreter','latex')
legend('vertical shear','horizontal shear')
xlabel('time [s]')

% -------------------------------------------------------------------------
figure('Name','Blade Loads')

% rotating frame
subplot(211)
hold on;box on;grid on;
plot(tout,logsout.get('M_oop_1').Values.Data/1e6)
plot(tout,logsout.get('M_oop_2').Values.Data/1e6)
plot(tout,logsout.get('M_oop_3').Values.Data/1e6)
ylabel('$M_{oop}$ [MNm]','Interpreter','latex')
legend( 'out-of-plane bending moment blade 1',...
        'out-of-plane bending moment blade 2',...
        'out-of-plane bending moment blade 3')

% fixed frame
subplot(212)
hold on;box on;grid on;
plot(tout,logsout.get('logFB').Values.M_V.Data/1e6)
plot(tout,logsout.get('logFB').Values.M_H.Data/1e6)
ylabel('$M_{V/H}$ [MNm]','Interpreter','latex')
legend( 'vertical Moment',...
        'horizontal Moment')    
xlabel('time [s]')

% -------------------------------------------------------------------------
figure('Name','Pitch Angles')

% rotating frame
subplot(311)
hold on;box on;grid on;
plot(tout,rad2deg(logsout.get('u').Values.theta_1_c.Data))
plot(tout,rad2deg(logsout.get('u').Values.theta_2_c.Data))
plot(tout,rad2deg(logsout.get('u').Values.theta_3_c.Data))
ylabel('$\theta_{c}$ [deg]','Interpreter','latex')
legend( 'pitch angle 1',...
        'pitch angle 2',...
        'pitch angle 3')
    
subplot(312)
hold on;box on;grid on;
plot(tout,rad2deg(logsout.get('theta_1_dot').Values.Data))
plot(tout,rad2deg(logsout.get('theta_2_dot').Values.Data))
plot(tout,rad2deg(logsout.get('theta_3_dot').Values.Data))
ylabel('$\dot \theta$ [deg/s]','Interpreter','latex')
legend( 'pitch rate 1',...
        'pitch rate 2',...
        'pitch rate 3')    

% fixed frame
subplot(313)
hold on;box on;grid on;
plot(tout,rad2deg(logsout.get('logFB').Values.theta_V_c.Data))  
plot(tout,rad2deg(logsout.get('logFB').Values.theta_H_c.Data))
ylabel('$\theta_{V/H}$ [deg]','Interpreter','latex')
legend( 'vertical pitch angle',...
        'horizontal pitch angle')    
xlabel('time [s]')