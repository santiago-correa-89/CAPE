% -----------------------------
% Script: Generates a time series for longitudional wind speed
% Exercise 07 of Course "Controller Design of Wind Turbines and Wind Farms"
% -----------------------------
clearvars;clc;close all;

%% part a)

% Configuration
URef    = 20;
IRef    = 0.16;

% standard deviation
b       = 5.6;
sigma   = IRef * (0.75*URef+b); 
L       = 8.1*42;

% frequency
f       = [0.001 0.01 0.1 1];
df      = f(1);

% spectrum
S       = sigma^2 * 4*L/URef ./ (1 + 6 * f * L/URef ).^(5/3);

% amplitudes
A       = sqrt(2*S*df);

% display
fprintf('The amplitudes are %5.3f, %5.3f, %5.3f, and %5.3f m/s\n',A)

%% part b)

% Configuration
T       = 4096;
dt      = 0.25;
f_max   = 2;

% frequency
f_min   = 1/T;
df      = f_min;
f       = [f_min:df:f_max];
n_f     = length(f);

% spectrum
S       = sigma^2 * 4*L/URef ./ (1 + 6 * f * L/URef ).^(5/3);

% amplitudes
A       = sqrt(2*S*df);

% init RNG
rng(1);

% phase angles
Phi     = rand(1,n_f)*2*pi;

% time
t       = 0:dt:T-dt;
n_t     = length(t); 

% generate time series         
tic
u       = URef * ones(1,n_t);     

% loop over frequencies
for i_f=1:n_f
    u   = u + A(i_f)*cos(2*pi*f(i_f)*t+Phi(i_f));    
end
toc

% inverse FFT
tic
U       = n_f*A.*exp(1i*Phi);
u_ifft  = URef+ifft([0 U],n_t,'symmetric');
toc

figure
hold on
plot(t,u,'o-')
plot(t,u_ifft,'.-')
xlabel('time [s]')
ylabel('wind speed [m/s]')


%% part c)

% estimate spectra
nBlocks                 = 1;
SamplingFrequency       = 1/dt;
n_FFT                   = n_t/nBlocks;
[S_est,f_est]           = pwelch(u-URef,ones(n_FFT,1)./n_FFT,0,n_FFT,SamplingFrequency);

figure
hold on;grid on;box on
plot(f,S,'o-')
plot(f_est,S_est,'.-')
set(gca,'xScale','log')
set(gca,'yScale','log')
xlabel('frequency [Hz]')
ylabel('Spectrum [(m/s)^2/Hz]')
legend('analytic','estimated')

%% part d)

% display
fprintf('%5.3f m/s: Standard deviation via numerical integration.\n',sqrt(sum(S)*df))
fprintf('%5.3f m/s: Standard deviation from standard.\n',sigma)
fprintf('%5.3f m/s: Standard deviation from time series.\n',std(u))

%% part e)

% coherence is exp(-kappa.*Distance)
kappa               = 12*((f/URef).^2+(0.12/L).^2).^0.5;

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
                SUM_gamma_uu    = SUM_gamma_uu + exp(-kappa.*Distance);
            end
        end
     end
end

% spectra rotor-effective wind speed
S_RR = S/nPointInRotorDisc^2.*SUM_gamma_uu;

plot(f,S_RR)
legend('single point model','single point estimated', 'rotor model')