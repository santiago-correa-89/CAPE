% -----------------------------
% Script: Estimates the spectra of a two Beam Lidar,
% Exercise 10 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------
%% 1. Initialization 
clear all;close all;clc;

%% 2. Simulate lidar
% Generate a turbulent wind field using TurbSim
OutputFile = 'TurbSim2a_Solution.wnd';
if ~exist(OutputFile,'file') % only run TurbSim if out file does not exist
    dos('TurbSim_x64.exe TurbSim2a_Solution.inp');
end

% Read the wind field into Matlab with readBLgrid.m
[velocity, y, z, nz, ny, dz, dy, dt, zHub, z1, SummVars] = readBLgrid(OutputFile);

% extract values from Summary Variables
URef        = SummVars(3);

% time vector
T           = size(velocity,1)*dt;
t         	= [0:dt:T-dt];

% coordinates in Wind-Coordinate System
x_1         = -80;
x_2         = -80;
y_1         = 20;
y_2         = -20;
z_1         = 0;
z_2         = 0;

% backscattered laser vector
f_1         = norm([x_1 y_1 z_1]);
f_2         = norm([x_2 y_2 z_2]);
x_n_1       = -x_1/f_1;
x_n_2       = -x_2/f_2;
y_n_1       = -y_1/f_1;
y_n_2       = -y_2/f_2;
z_n_1       = -z_1/f_1;
z_n_2       = -z_2/f_2;

% extract wind from wind field
idx_y_1   	= y_1==y;
idx_z_1    	= z_1==y;
u_1      	= velocity(:,1,idx_y_1,idx_z_1);
v_1       	= velocity(:,2,idx_y_1,idx_z_1);
w_1      	= velocity(:,3,idx_y_1,idx_z_1);
idx_y_2    	= y_2==y;
idx_z_2   	= z_2==y;
u_2      	= velocity(:,1,idx_y_2,idx_z_2);
v_2      	= velocity(:,2,idx_y_2,idx_z_2);
w_2       	= velocity(:,3,idx_y_2,idx_z_2);

% calculate line-of-sight wind speeds
v_los_1   	= u_1*x_n_1+v_1*y_n_1+w_1*z_n_1; 
v_los_2   	= u_2*x_n_2+v_2*y_n_2+w_2*z_n_2;

%% 3. Reconstruction
% estimation of u component
u_1_est     = v_los_1/x_n_1; % Divide de V_l por el vector direccional normalizada. Supongo v=w=0
u_2_est     = v_los_2/x_n_2; % 

% estimation of rotor-effective wind speed
v_0L        = (u_1_est + u_2_est)/2 ;

%% 4. Estimation of Spectrum from Data
signal               	= detrend(v_0L,'constant');
nBlocks                 = 16;
nOverlap                = [];   % default: nDataPerBlock/2;
SamplingFrequency       = 1/dt;
nDataPerBlock           = floor(size(signal,1)/nBlocks/2)*2; % should be even
nFFT                    = 2^nextpow2(nDataPerBlock);
vWindow                 = hamming(nDataPerBlock);

[S_LL_est, f_est]        = pwelch(signal,vWindow,nOverlap,nFFT,SamplingFrequency); 

%% 5. Definition of the Kaimal spectrum

% frequency
f_max       = 1/2*1/dt;
f_min       = 1/T;
df          = f_min;
f           = [f_min:df:f_max];

% from [IEC 61400-1 third edition 2005-08 Wind turbines - Part 1: Design requirements 2005]
L_1         = 8.1   *42;
L_2         = 2.7   *42;
L_3         = 0.66  *42;
sigma_1     = 0.16*(0.75*URef+5.6);
sigma_2     = sigma_1*0.8;
sigma_3     = sigma_1*0.5;

% Spectra
S_uu        = (4*L_1/URef./((1+6*f*L_1/URef).^(5/3))*sigma_1^2);
S_vv        = (4*L_2/URef./((1+6*f*L_2/URef).^(5/3))*sigma_2^2);
S_ww        = (4*L_3/URef./((1+6*f*L_3/URef).^(5/3))*sigma_3^2);

% Coherence
Distance    = sqrt((y_1-y_2)^2+(z_1-z_2)^2); % distance in y-z plane
kappa       = 12*((f/URef).^2+(0.12/L_1).^2).^0.5;
gamma_uu    = exp(-kappa.*Distance); % coherence between point 1 and 2 in u

%% 6. Analytic spectrum of rotor effective wind speed estimate
S_LL        = (1/4)*(2*S_uu + 2*y_n_1^2/x_n_1^2*S_vv +  2*S_uu.*gamma_uu); % Currently, this is the analytic spectrum of v_los_1

%% 7. Analytic spectrum of rotor effective wind speed
R                   = 63;
[Y,Z]               = meshgrid(-64:4:64,-64:4:64);
DistanceToHub       = (Y(:).^2+Z(:).^2).^0.5;
nPoint              = length(DistanceToHub);
IsInRotorDisc       = DistanceToHub<=R;
nPointInRotorDisc   = sum(IsInRotorDisc);

% loop over ...
SUM_gamma_uu       	= zeros(size(f));       % allocation
for iPoint=1:1:nPoint                       % ... all iPoints
    if IsInRotorDisc(iPoint)
        for jPoint=1:1:nPoint               % ... all jPoints
            if IsInRotorDisc(jPoint)
                Distance        = ((Y(jPoint)-Y(iPoint))^2+(Z(jPoint)-Z(iPoint))^2)^0.5;
                SUM_gamma_uu    = SUM_gamma_uu + exp(-kappa.*Distance); % needs correction !!!
            end
        end
     end
end

% spectra rotor-effective wind speed
S_RR                = S_uu.*SUM_gamma_uu/(nPointInRotorDisc^2);         % needs correction !!!

%% 8. Analytic cross-spectrum 
% cross-spectra rotor-effective wind speed and its lidar estimate

SUM_gamma_1n       	= zeros(size(f));       % allocation
SUM_gamma_2n       	= zeros(size(f));       % allocation

for Point=1:1:nPoint                       % ... all iPoints
    if IsInRotorDisc(Point)
        Distance_1      = ((y_1-Y(Point))^2+(z_1-Z(Point))^2)^0.5;
        Distance_2      = ((y_2-Y(Point))^2+(z_2-Z(Point))^2)^0.5;
        SUM_gamma_1n    = SUM_gamma_1n + exp(-kappa.*Distance_1);
        SUM_gamma_2n    = SUM_gamma_2n + exp(-kappa.*Distance_2);
     end
end

S_RL                = (1/2*nPointInRotorDisc)*(S_uu.*SUM_gamma_1n + S_uu.*SUM_gamma_2n);    %  

%% 9. Coherence
gamma_Sq_RL         = S_RL/sqrt(S_LL.*S_uu); % needs correction !!!
k                   = 2*pi*f./v_0L;           % needs correction !!!
MCB                 = NaN;          % needs correction !!!
SDES                = NaN;          % needs correction !!!

%% 10. Plots
% time
figure('Name','Time')
hold all; grid on; box on
plot(t,v_los_1,'.-')
plot(t,v_los_2,'.-')
plot(t,v_0L,'.-')
xlim([0 30])
xlabel('time [s]')
ylabel('wind speeds [m/s]')
legend('v_{los,1}','v_{los,2}','v_{0L}')

% frequency
figure('Name','Spectra')
hold all; grid on; box on
plot(f_est,S_LL_est)
plot(f,S_LL)
plot(f,S_uu)
plot(f,S_RR)
xlim([1e-3 1e0])
set(gca,'xScale','log')
set(gca,'yScale','log')
xlabel('frequency [Hz]')
ylabel('spectra [(m/s)^2/Hz]')
legend('S_{LL,est}','S_{LL}','S_{uu}','S_{RR}')

% coherence
figure('Name','Coherence')
hold all; grid on; box on
plot(k,gamma_Sq_RL)
plot([1e-3 1e0],[0.5 0.5])
plot(MCB,0.5,'o')
xlim([1e-3 1e0])
set(gca,'xScale','log')
xlabel('wave number [rad/m]')
ylabel('coherence [-]')