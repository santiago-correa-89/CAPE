% -----------------------------
% Script: Calculates wake losses for a 2x2 wind farm.
% Exercise 12 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------
clearvars;clc;close all

rho             = 1.225;
k_w             = 0.075;
R               = 63;
D               = 2*R;
A               = pi*R^2;
u_1             = 10;
c_T             = 0.8;
c_P             = 0.48;
nTurbine        = 4;

%% a)  In case of westerly wind direction, what is the wind speed at the downwind row? 
delta_x_West    = 7*D; % needs adjustment
u_2_West        = JensenWakeModel(u_1,k_w,R,c_T,delta_x_West);
fprintf('Wind from the West: Wind speed at the second wind turbine row: %4.2f m/s \n',u_2_West);

%% b) How wide is then the wake impacted area?
r_wake_West     = k_w*delta_x_West + R; % needs adjustment
fprintf('Wind from the West: Wake impacted area at the 2nd row: %4.2f m \n',r_wake_West*2);

%% c) How large are the wake losses in percent in this situation for the full wind farm? 
P_Turbine_NoWake   = (1/2)*rho*A*c_P*u_1^3 ;
P_Turbine_WakeWest = (1/2)*rho*A*c_P*u_2_West^3 ;
P_Farm_West        = 2*(P_Turbine_WakeWest + P_Turbine_NoWake); % needs adjustment

% calculation of losses
P_Farm_NoLosses = 4*P_Turbine_NoWake; % needs adjustment
Losses_West     = 1 - P_Farm_West/P_Farm_NoLosses; % needs adjustment

fprintf('Wind from the West: Wake losses: %4.2f %% \n',Losses_West*100);

%% d) How do wind speed, wake impacted area, and wake losses change for southerly wind direction?
delta_x_South   = 0; % needs adjustment
u_2_South       = JensenWakeModel(u_1,k_w,R,c_T,delta_x_South);
fprintf('Wind from the South: Wind speed at the second wind turbine row: %4.2f m/s \n',u_2_South);
r_wake_South    = 0; % needs adjustment
fprintf('Wind from the South: Wake impacted area at the 2nd row: %4.2f m \n',r_wake_South*2);
P_Farm_South    = 0; % needs adjustment
Losses_South    = 0; % needs adjustment
fprintf('Wind from the South: Wake losses: %4.2f %% \n',Losses_South*100);

%% e) What are the coordinates of all 4 wind turbines in the inertia coordinate system?
% (1) south-west, (2) south-east, (3) north-west, (4) north east
x_I             = [ 0 7 0 7 ]*D; % needs adjustment 
y_I             = [ 0 0 5 5 ]*D; % needs adjustment

%% f)+g) What are the coordinates of all 4 wind turbines in the wind coordinate system for westerly wind?

WindDirection   = 270;  % [deg] West
alpha           = 0; % needs adjustment
T               = [cosd(alpha) sind(alpha); -sind(alpha) cosd(alpha)]; % needs adjustment
x_W             = T(1,1)*x_I + T(1,2)*y_I; 
y_W             = T(2,1)*x_I + T(2,2)*y_I; 

% And for southerly wind?
WindDirection 	= 180;   % [deg] South
alpha           = 90; % needs adjustment
T               = [cosd(alpha) sind(alpha); -sind(alpha) cosd(alpha)]; % needs adjustment
x_S             = T(1,1)*x_I + T(1,2)*y_I; 
y_S             = T(2,1)*x_I + T(2,2)*y_I; 

%% i) How large are the overall wake losses assuming equally distributed wind directions? 
WindDirection_v = [0:1:359];
nWindDirection  = length(WindDirection_v);

% Allocation
P_Turbine       = NaN(nWindDirection,nTurbine); 
P_Farm          = NaN(nWindDirection,1); 

% loop over wind directions
for iWindDirection  = 1:nWindDirection
    WindDirection   = WindDirection_v(iWindDirection);
    
    alpha           = 0; % needs adjustment
    T               = [0 0; 0 0]; % needs adjustment
    x_W             = T(1,1)*x_I + T(1,2)*y_I; 
    y_W             = T(2,1)*x_I + T(2,2)*y_I; 
     
    % loop over turbines
    for iTurbine = 1:nTurbine % current turbine
        delta = zeros(nTurbine,1);
        for jTurbine = 1:nTurbine % impact on current turbine i
            % Distance from Trubine i to j
            delta_x = 0;  % needs adjustment 
            delta_y = 0;  % needs adjustment           
            % u_2 for current turbine i
            u_2     = JensenWakeModelLinearApproximation(u_1,k_w,R,c_T,delta_x,delta_y);
            % speed deficit of turbine j on current turbine i 
            delta(jTurbine) = 0;  % needs adjustment
        end
        % speed deficit of all turbines on current turbine i
        delta_n = 0;  % needs adjustment
        % speed at current turbine i 
        u_n     = 0;  % needs adjustment
        % power at current turbine i 
        P_Turbine(iWindDirection,iTurbine) = 0;  % needs adjustment
    end    
    % power of the wind farm at current wind direction
    P_Farm(iWindDirection) = 0;  % needs adjustment
end

% calculation of losses
Losses      = 0;  % needs adjustment

fprintf('Wake losses for this wind speed: %4.2f %% \n',Losses*100);


%%
figure
title('Power of wind turbines')
hold on;grid on;box on 
plot(WindDirection_v,P_Turbine/1e6)
xlim([0 360])
set(gca,'xTick',[0:90:360])
legend(strcat({'turbine '},num2str([1:nTurbine]')))
xlabel('wind direction [deg]')
ylabel('power [MW]')

figure
title('Power of wind farm')
hold on;grid on;box on 
plot(WindDirection_v,P_Farm/1e6)
xlim([0 360])
set(gca,'xTick',[0:90:360])
xlabel('wind direction [deg]')
ylabel('power [MW]')