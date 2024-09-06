clear all; clc; close all;

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
u = ones(size(t))*u_mean ;
for i_f = 1:n_f
    u   = u + a(i_f)*cos(2*pi*f(i_f)*t + phi(i_f));
end

figure
plot(t,u)
xlabel('time [s]')
ylabel('u [m/s]')

u_spectrum = sqrt(sum(S_11)*df) ;