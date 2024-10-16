% -----------------------------
% Script: Tests Baseline Torque Controller.
% Exercise 02 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------

clearvars;close all;clc;

%% PreProcessing SLOW

% Default Parameter Turbine and Controller
Parameter                       = NREL5MWDefaultParameter_SLOW1DOF;
Parameter                       = NREL5MWDefaultParameter_FBNREL_Solution(Parameter);

% Time
dt                              = 1/80;
Parameter.Time.dt               = dt;   % [s] simulation time step              
Parameter.Time.TMax             = 60;   % [s] simulation length

% wind
Disturbance.v_0.time            = [0; 30; 30+dt; 60]; % [s]      time points to change wind speed
Disturbance.v_0.signals.values  = [8;  8;     9;  9]; % [m/s]    wind speeds

% Initial Conditions from SteadyStates
SteadyStates = load('SteadyStatesNREL5MW_FBNREL_SLOW','v_0','Omega','theta');                       
Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega   ,8,'linear','extrap');
Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta   ,8,'linear','extrap');


%% Processing SLOW
sim('NREL5MW_FBNREL_SLOW1DOF_Solution.mdl')

%% Processing FAST
OutputFile  = 'FAST/TorqueControllerTest.out';
if ~exist(OutputFile,'file') % only run FAST if out file does not exist
    cd FAST
    dos('FAST_Win32.exe TorqueControllerTest.fst');
    cd ..
end

%% PostProcessing FAST
fid         = fopen(OutputFile);
formatSpec  = repmat('%f',1,10);
FASTResults = textscan(fid,formatSpec,'HeaderLines',8);
Time        = FASTResults{:,1};
Wind1VelX   = FASTResults{:,2};
RotSpeed    = FASTResults{:,4};
GenTq       = FASTResults{:,10};
GenPwr      = FASTResults{:,9};
TSR         = RotSpeed/60*2*pi*Parameter.Turbine.R./Wind1VelX;
fclose(fid)

%% PostProcessing SLOW
figure

% plot wind
subplot(511)
hold on;box on;grid on;
plot(tout,logsout.get('d').Values.v_0.Data)
plot(Time,Wind1VelX)
ylabel('v_0 [m/s]')

% plot generator torque
subplot(512)
hold on;box on;grid on;
plot(tout,logsout.get('u').Values.M_g_c.Data/1e3)
plot(Time,GenTq)
ylabel('M_G [kNm]')

% plot rotor speed
subplot(513)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.Omega.Data*60/2/pi)
plot(Time,RotSpeed)
ylabel('\Omega [rpm]')

% plot tip speed ratio
subplot(514)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.lambda.Data)
plot(Time,TSR)
ylabel('\lambda [-]')

% plot power
subplot(515)
hold on;box on;grid on;
plot(tout,logsout.get('y').Values.P_el.Data/1e6)
plot(Time,GenPwr/1e3)
ylabel('P [MW]')
xlabel('time [s]')

