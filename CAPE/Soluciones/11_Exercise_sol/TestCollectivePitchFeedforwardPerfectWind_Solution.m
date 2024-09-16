% -----------------------------
% Script: Tests Collective Pitch Feedforward Controller with perfect wind
% preview.
% Exercise 11 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------

clearvars;close all;clc;

%% PreProcessing SLOW for all simulations

% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW3DOF;
Parameter                       = NREL5MWDefaultParameter_FBSWE(Parameter);
Parameter                       = NREL5MWDefaultParameter_FF(Parameter);

% Time
dt                              = 1/80;
Parameter.Time.dt               = dt;   % [s] simulation time step              
Parameter.Time.TMax             = 30;   % [s] simulation lenght

% Wind: Extreme Operating Gust (EOG)
OP                              = 25;
load('EOG25.mat','Disturbance')

% Perfect 5s Wind Preview from Lidar
Disturbance.v_0L                = Disturbance.v_0;
Disturbance.v_0L.time           = Disturbance.v_0L.time-5;

% Initial Conditions from SteadyStates 
SteadyStates                    = load('SteadyStatesNREL5MW_FBSWE_SLOW','v_0','Omega','theta','x_T','M_g');                       
Parameter.IC.Omega              = interp1(SteadyStates.v_0,SteadyStates.Omega   ,OP,'linear','extrap');
Parameter.IC.theta              = interp1(SteadyStates.v_0,SteadyStates.theta   ,OP,'linear','extrap');
Parameter.IC.x_T                = interp1(SteadyStates.v_0,SteadyStates.x_T     ,OP,'linear','extrap');
Parameter.IC.M_g                = interp1(SteadyStates.v_0,SteadyStates.M_g     ,OP,'linear','extrap');

%% Feedback only
Parameter.CPC.FF.Mode                	= 0;

sim('NREL5MW_FBSWE_SLOW3DOF_Solution.mdl')
% collect simulation Data
theta_FB    = logsout.get('y').Values.theta.Data;
Omega_FB    = logsout.get('y').Values.Omega.Data;
M_yT_FB     = logsout.get('y').Values.M_yT.Data;
M_yT_FB_max = max(abs(M_yT_FB));                                            % needs adjustment !!!


%% Brute-Force-Optimization
T_Buffer_v  = 4.7;%[4.5:0.1:5];                                            	% needs adjustment !!!
n_T_Buffer  = length(T_Buffer_v);
Parameter.CPC.FF.Mode               = 1;

for i_T_Buffer=1:n_T_Buffer
    
    % adjust Buffer Time
    Parameter.CPC.FF.T_buffer       = T_Buffer_v(i_T_Buffer);

    % Processing SLOW for this OP
    sim('NREL5MW_FBSWE_SLOW3DOF_Solution.mdl')
    
    % collect simulation Data
    theta_FF(:,i_T_Buffer)          = logsout.get('y').Values.theta.Data;
    Omega_FF(:,i_T_Buffer)          = logsout.get('y').Values.Omega.Data;
    M_yT_FF(:,i_T_Buffer)           = logsout.get('y').Values.M_yT.Data;
   
    % calculate ultimate load
    M_yT_FF_max(i_T_Buffer)         = max(abs(M_yT_FF(:,i_T_Buffer)));     	% needs adjustment !!!
    
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
plot([min(T_Buffer_v) max(T_Buffer_v)],[1 1]*M_yT_FB_max/1e6)
plot(T_Buffer_v,M_yT_FF_max/1e6,'.-')
xlabel('T_{Buffer} [s]')
ylabel('Ultimate tower load [MNm]')
legend('FB only','FB+FF')