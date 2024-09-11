% -----------------------------
% Script: Tests Baseline Torque Controller.
% Exercise 02 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------

clearvars;close all;clc;

% find lambda to have 99% of power => lambda = 7
load('PowerAndThrustCoefficientsNREL5MW.mat')

figure
hold on;box on;grid on;
plot(lambda,c_P(:,1)/max(c_P(:,1)))
plot(7,0.99,'o')
ylim([0.99 1])
xlabel('\lambda [-]')
ylabel('c_P/max(c_P) [-]')

% calculate new parameters
Parameter                       = NREL5MWDefaultParameter_SLOW1DOF;
Parameter                       = NREL5MWDefaultParameter_FBNREL_LowNoise_Solution(Parameter);

% parameter, which needs to be copied into *.in file
fprintf('Parameter.VSC.k              = %f\n',Parameter.VSC.k);
fprintf('Parameter.VSC.a_1_5          = %f\n',Parameter.VSC.a_1_5);
fprintf('Parameter.VSC.b_1_5          = %f\n',Parameter.VSC.b_1_5);
fprintf('Parameter.VSC.a_2_5          = %f\n',Parameter.VSC.a_2_5);
fprintf('Parameter.VSC.b_2_5          = %f\n',Parameter.VSC.b_2_5);

%% Processing FAST
OutputFile  = 'FAST/LowNoise_Solution.out';
if ~exist(OutputFile,'file') % only run FAST if out file does not exist
    cd FAST
    dos('FAST_Win32.exe LowNoise_Solution.fst');
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

figure

% plot wind
subplot(511)
hold on;box on;grid on;
plot(Time,Wind1VelX)
ylabel('v_0 [m/s]')

% plot generator torque
subplot(512)
hold on;box on;grid on;
plot(Time,GenTq)
ylabel('M_G [kNm]')

% plot rotor speed
subplot(513)
hold on;box on;grid on;
plot(Time,RotSpeed)
ylabel('\Omega [rpm]')

% plot tip speed ratio
subplot(514)
hold on;box on;grid on;
plot(Time,TSR)
ylabel('\lambda [-]')

% plot power
subplot(515)
hold on;box on;grid on;
plot(Time,GenPwr/1e3)
ylabel('P [MW]')
xlabel('time [s]')

