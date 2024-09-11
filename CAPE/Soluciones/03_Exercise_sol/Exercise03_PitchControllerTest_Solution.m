% -----------------------------
% Script: Tests pitch controller at different operation points.
% Exercise 03 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------

clearvars;close all;clc;

%% PreProcessing SLOW for all simulations

% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW1DOF;
Parameter                       = NREL5MWDefaultParameter_FBNREL_PitchController_Solution(Parameter);

% Time
dt                              = 1/80;
Parameter.Time.dt               = dt;   % [s] simulation time step              
Parameter.Time.TMax             = 60;   % [s] simulation length

%% Loop over Operation Points

OPs = [12 16 20 24];
nOP = length(OPs);

for iOP=1:nOP
    
    % get Operation Point
    OP = OPs(iOP);

    % wind for this OP
    Disturbance.v_0.time            = [0; 30; 30+dt;  60];       % [s]      time points to change wind speed
    Disturbance.v_0.signals.values  = [0;  0;   0.1; 0.1]+OP;    % [m/s]    wind speeds

    % Initial Conditions from SteadyStates for this OP
    SteadyStates = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta');                       
    Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega,OP,'linear','extrap');
    Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta,OP,'linear','extrap');

    % Processing SLOW for this OP
    sim('NREL5MW_FBNREL_SLOW1DOF_PitchController_Solution.mdl')
    
    % collect simulation Data
    Omega(:,iOP) = logsout.get('y').Values.Omega.Data;
    OmegaNormalized(:,iOP) = (Omega(:,iOP)-rpm2radPs(12.1))/(max(Omega(:,iOP))-rpm2radPs(12.1));
    
end


%% PostProcessing SLOW
figure

subplot(211)
hold on;box on;grid on;
plot(tout,Omega*60/2/pi)
ylabel('\Omega [rpm]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(212)
hold on;box on;grid on;
plot(tout,OmegaNormalized)
ylabel('Normalized \Omega [-]')
xlabel('time [s]')


%% compare it to step
D_d         = 0.7;
omega_d     = 0.5;

% get closed-loop tf
CL = tf([omega_d^2 0],[1 2*D_d*omega_d omega_d^2]);
    
% step 
[y,t] = step(CL,tout-30);
yNormalized  = y./max(y);

% plot
subplot(212)
plot(t+30,yNormalized,'k--')  