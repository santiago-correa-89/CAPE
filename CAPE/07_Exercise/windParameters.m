clearvars all; clc; close all;

% configuration
I_Ref   = 0.16 ; % [m/s]
u_mean  = 20   ; % [-]
T       = 4096 ; % [s]
dt      = 0.25 ; % [s]
seed    = 1 ;

% time vector
t  = 0:dt:T-dt ; % [s] tomo hasta T-1, ya que al ser una función periodica la velocidad se 
                 % el primero y el ultimo valor se repiten por lo que pare
                 % enlazar las funciones es mejor tomar un valor menos y
                 % enlazar un periodo identico al primero.

% Frequency sampling
f_min   = 1/T   ; %[Hz]
df      = f_min ; % Frequency step
f_max   = 2     ; %[Hz]
f       = f_min:df:f_max ; % Frequency vector
n_f     = length(f) ;
n_t     = length(t) ;

% Values from standar IEC
lambda1 = 42          ;
L_1     = 8.1*lambda1 ;
b       = 5.6         ; 

% Standard Deviation
sigma_1 = I_Ref * (0.75*u_mean + b) ;

% Spectrum
S_11    = ( sigma_1^2 ) * ( 4 *L_1 / u_mean ) ./ ( 1 + 6 * f *L_1 / u_mean ).^(5/3) ;

% Amplitudes
a       = sqrt(2*S_11*df);

% Random seed of phase angle
rng(seed) ;
phi = rand(1,n_f)*2*pi ;

% Wind
tic
u = ones(size(t))*u_mean ;
for i_f = 1:n_f
    u   = u + a(i_f)*cos(2*pi*f(i_f)*t + phi(i_f));
end
toc 

% inverse FFT
tic
U = n_f*a.*exp(1i*phi);
u_ifft = u_mean + ifft([0 U], n_t, 'symmetric');
toc

figure
plot(t,u)
hold on 
plot(t, u_ifft, 'or')
xlabel('time [s]')
ylabel('u [m/s]')

u_spectrum = sqrt(sum(S_11)*df) ;

%% Part C
nBlocks           = 1    ;
SamplingFrequency = 1/dt ;
n_FFT              = 1; % complete