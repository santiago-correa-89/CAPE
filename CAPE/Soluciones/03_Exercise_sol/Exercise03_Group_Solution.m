% -----------------------------
% Script: Test Pitch Controller at different Operation Points
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
Parameter.Time.TMax             = 60;   % [s] simulation lenght

%% Loop over Operation Points

% get Operation Point
OP = 20;

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
Omega = logsout.get('y').Values.Omega.Data;
OmegaNormalized = (Omega-rpm2radPs(12.1))/(max(Omega)-rpm2radPs(12.1));    

%% Processing FAST
OutputFile  = 'FAST/PitchControllerTest.outb';
if ~exist(OutputFile,'file') % only run FAST if out file does not exist
    cd FAST
    dos('FAST_Win32.exe PitchControllerTest.fst');
    cd ..
end

%% PostProcessing FAST
[FASTResults, OutList, ~, ~, ~]    = ReadFASTbinary(OutputFile);
Time        = FASTResults(:,strcmp(OutList,'Time'));
RotSpeed    = FASTResults(:,strcmp(OutList,'RotSpeed'));

%% PostProcessing
figure
hold on;box on;grid on;
plot(tout,Omega*60/2/pi)
plot(Time,RotSpeed)
ylabel('\Omega [rpm]')
xlim([20 60])   
legend('SLOW','FAST')
