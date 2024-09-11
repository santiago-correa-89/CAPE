% -----------------------------
% Script: Generates a wind field with TurbSim and analizes it.
% Exercise 07 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ------------
% Task:
% 
% ------------
% History:
% v01:  David Schlipf on 22-Nov-2021
% ----------------------------------
clearvars;clc;close all;

%% a) Generate a turbulent wind field with the same grid resolution and spectral properties as above using TurbSim.
OutputFile = 'TurbSim2a_Solution.wnd';
if ~exist(OutputFile,'file') % only run TurbSim if out file does not exist
    dos('TurbSim_x64.exe TurbSim2a_Solution.inp');
end

%% b) Read the wind field into Matlab with readBLgrid.m.
[velocity, y, z, nz, ny, dz, dy, dt, zHub, z1, SummVars] = readBLgrid(OutputFile);

%% c) Compare the analytic spectrum of a single point with an estimated one for the wind at hub height using pwelch.

% extract signal
idx_y               = y==0;
idx_z               = (z-zHub)==0;
u                   = velocity(:,1,idx_y,idx_z);

% frequency
T       = size(velocity,1)*dt;
f_max   = 1/2*1/dt;
f_min   = 1/T;
df      = f_min;
f       = [f_min:df:f_max];
n_f     = length(f);

% SummVars
URef    = SummVars(3);
sigma   = SummVars(4)/100*URef;
h       = SummVars(1);

% Length scale IEC
L       = 8.1*42;

% time
t       = 0:dt:T-dt;
n_t     = length(t); 

% spectrum
S       = sigma^2 * 4*L/URef ./ (1 + 6 * f * L/URef ).^(5/3);

% estimation
nBlocks                     = 16;
SamplingFrequency           = 1/dt;
n_FFT                       = n_t/nBlocks;
[S_est,f_est]               = pwelch(u-mean(u),hamming(n_FFT),[],n_FFT,SamplingFrequency);

% plot
figure
hold on;grid on;box on
plot(f_est,S_est,'.-')
plot(f,S,'-')
set(gca,'xScale','log')
set(gca,'yScale','log')
xlabel('frequency [Hz]')
ylabel('Spectrum [(m/s)^2/Hz]')
legend('estimate','analytic')

%% d) Compare the analytic spectrum of the rotor-effective wind speed with the estimated one using pwelch.
kappa               = 12*((f/URef).^2+(0.12/L).^2).^0.5;
R                   = 63;
[Y,Z]               = meshgrid(y,z-h);
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
                SUM_gamma_uu    = SUM_gamma_uu + exp(-kappa.*Distance);
            end
        end
     end
end

% spectra rotor-effective wind speed
S_RR = S/nPointInRotorDisc^2.*SUM_gamma_uu;

% get rotor-effective wind speed
v_0     = NaN(n_t,1);
for i_t = 1:1:n_t
    CurrentWind     = squeeze(velocity(i_t,1,:,:)); 
    WindField       = CurrentWind(IsInRotorDisc);
  	v_0(i_t,1)      = mean(WindField);
end

% estimation
nBlocks                     = 16;
SamplingFrequency           = 1/dt;
n_FFT                       = n_t/nBlocks;
[S_est,f_est]               = pwelch(v_0-mean(v_0),hamming(n_FFT),[],n_FFT,SamplingFrequency);

% plot
figure
hold on;grid on;box on
plot(t,u)
plot(t,v_0)
xlabel('time [s]')
ylabel('wind speed [m/s]')
legend('hub height','rotor')

% plot
figure
hold on;grid on;box on
plot(f_est,S_est,'.-')
plot(f,S_RR,'-')
set(gca,'xScale','log')
set(gca,'yScale','log')
xlabel('frequency [Hz]')
ylabel('Spectrum [(m/s)^2/Hz]')
legend('estimate','analytic')

%% e) Compare the analytic coherence with an estimated one from two points at hub height with a distance of 20m using mscohere.

% get signals
idx_y_1             = 17;
idx_y_2             = 22;
idx_z_1             = 17;
idx_z_2             = 17;
u_1                 = velocity(:,1,idx_y_1,idx_z_1);
u_2                 = velocity(:,1,idx_y_2,idx_z_2);
Distance            = ((y(idx_y_1)-y(idx_y_2))^2+(z(idx_z_1)-z(idx_z_2))^2)^0.5;
fprintf('Distance: %4.1f m.\n',Distance)

% coherence gamma = exp(-kappa.*Distance)
gamma               = exp(-kappa.*Distance);

% estimate coherence
nBlocks           	= 16;
SamplingFrequency   = 1/dt;
n_FFT           	= n_t/nBlocks;
[gamma_Sq_est,f_est]= mscohere(u_1-mean(u_1),u_2-mean(u_2),hamming(n_FFT),[],n_FFT,SamplingFrequency);

figure
hold on;grid on;box on
plot(f_est,gamma_Sq_est,'-')
plot(f,gamma.^2,'-')
set(gca,'xScale','log')
xlabel('frequency [Hz]')
ylabel('Squared Coherence [-]')
legend('estimate','analytic')
