clearvars;close all;clc;
Parameter.Turbine.SS             	    = load('PowerAndThrustCoefficientsNREL5MW','c_P','theta','lambda'); % load Power coefficient look-up-table
lambda_opt                              = 7.55;                             % [-]
theta_opt                               = 0;                                % [deg]
theta                                   = Parameter.Turbine.SS.theta;
lambda                               	= Parameter.Turbine.SS.lambda;
c_P                                     = Parameter.Turbine.SS.c_P;
c_P_opt                                 = interp2(theta,lambda,c_P,theta_opt,lambda_opt);
idx_opt                                 = find(theta==theta_opt);
[c_P_max,idx_max]                       = max(c_P(:,idx_opt));
lambda_max                              = lambda(idx_max);
fprintf('TSR for maximum c_P: %f\n',lambda_max)
fprintf('Increase in power: %f %%\n',100*(c_P_max/c_P_opt-1))

figure
hold on;grid on;box on
plot(lambda,c_P(:,idx_opt))
plot(lambda_max,c_P_max,'o')


%% Plot c_P curves for different pitch angles
Idx = 1:5:6;

figure
hold on;grid on;box on
plot(lambda,c_P(:,Idx),'.-')
plot(lambda_opt,c_P_opt,'ko')
legend(rad2deg(theta(Idx)')+" deg",'location','best')
xlim([6.0 9.0])
xlabel('\lambda [-]')
ylabel('c_P [-]')
