% -----------------------------
% Script: Tests Collective Pitch Feedforward Controller with realistic wind
% preview
% Exercise 11 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------

clearvars;close all;clc;

%% PreProcessing SLOW for all simulations

% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW3DOF;
Parameter                       = NREL5MWDefaultParameter_FBSWE(Parameter);
Parameter                       = NREL5MWDefaultParameter_FF(Parameter);

% Enable and adjust filter
Parameter.Filter.LowPass3.Enable       	= 1;            % [0/1]
Parameter.Filter.LowPass3.f_cutoff     	= 1;            % [Hz]   

% Time
dt                              = 1/80;
Parameter.Time.dt               = dt;       % [s] simulation time step              
Parameter.Time.TMax             = 2^16*dt;  % [s] simulation lenght

% Wind and realistic lidar preview
OP                              = 20;
load('TurbulentWind20','Disturbance');

% Initial Conditions from SteadyStates 
SteadyStates                    = load('SteadyStatesNREL5MW_FBSWE_SLOW','v_0','Omega','theta','x_T','M_g');                       
Parameter.IC.Omega              = interp1(SteadyStates.v_0,SteadyStates.Omega   ,OP,'linear','extrap');
Parameter.IC.theta              = interp1(SteadyStates.v_0,SteadyStates.theta   ,OP,'linear','extrap');
Parameter.IC.x_T                = interp1(SteadyStates.v_0,SteadyStates.x_T     ,OP,'linear','extrap');
Parameter.IC.M_g                = interp1(SteadyStates.v_0,SteadyStates.M_g     ,OP,'linear','extrap');

% Postprocessing Parameter
WoehlerExponent                 = 4;            % [-]   for steel
N_REF                           = 2e6/(20*8760);% [-]   fraction of 2e6 in 20 years for 1h

%% Feedback only
Parameter.CPC.FF.Mode                	= 0;

sim('NREL5MW_FBSWE_SLOW3DOF_Ex11.mdl')
% collect simulation Data
theta_FB    = logsout.get('y').Values.theta.Data;
Omega_FB    = logsout.get('y').Values.Omega.Data;
M_yT_FB     = logsout.get('y').Values.M_yT.Data;
Omega_FB_std= std(Omega_FB);
c          	= rainflow(M_yT_FB);
Count    	= c(:,1);
Range     	= c(:,2);
DEL_MyT_FB  = 0;% needs correction !!!
                                            
%% Brute-Force-Optimization
T_Buffer_v  = 0;% needs correction !!!                                       	% needs adjustment !!!
n_T_Buffer  = length(T_Buffer_v);
Parameter.CPC.FF.Mode               = 1;

for i_T_Buffer=1:n_T_Buffer
    
    % adjust Buffer Time
    Parameter.CPC.FF.T_buffer       = T_Buffer_v(i_T_Buffer);

    % Processing SLOW for this OP
    sim('NREL5MW_FBSWE_SLOW3DOF_Ex11.mdl')
    
    % collect simulation Data
    theta_FF(:,i_T_Buffer)          = logsout.get('y').Values.theta.Data;
    Omega_FF(:,i_T_Buffer)          = logsout.get('y').Values.Omega.Data;
    M_yT_FF(:,i_T_Buffer)           = logsout.get('y').Values.M_yT.Data;
   
    % calculate fatigue load
    c                               = rainflow(M_yT_FF(:,i_T_Buffer));
    Count                           = c(:,1);
    Range                           = c(:,2);
    DEL_MyT_FF(i_T_Buffer)          = 0; % needs correction !!!
end

%% PostProcessing SLOW
figure
subplot(411)
hold on;box on;grid on;
plot(Disturbance.v_0.time,Disturbance.v_0.signals.values)
ylabel('v_{0} [m/s]')

subplot(412)
hold on;box on;grid on;
plot(tout,Omega_FB*60/2/pi,'k')
plot(tout,Omega_FF*60/2/pi)
ylabel('\Omega [rpm]')

subplot(413)
hold on;box on;grid on;
plot(tout,theta_FB*360/2/pi,'k')
plot(tout,theta_FF*360/2/pi)
ylabel('\theta [deg]')

subplot(414)
hold on;box on;grid on;
plot(tout,M_yT_FB/1e6,'k')
plot(tout,M_yT_FF/1e6)
ylabel('M_{yT} [MNm]')
xlabel('time [s]')
legend('FB only','FB+FF')

figure
hold on;box on;grid on;
plot([min(T_Buffer_v) max(T_Buffer_v)],[1 1]*DEL_MyT_FB/1e6)
plot(T_Buffer_v,DEL_MyT_FF/1e6,'.-')
xlabel('T_{Buffer} [s]')
ylabel('Fatigue tower load [MNm]')
legend('FB only','FB+FF')
