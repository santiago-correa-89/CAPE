# -*- coding: utf-8 -*-
"""

@author: Felipe Novais, Wei Fu, David Schlipf
"""
# Documentation about FLORIS can be found at: https://floris.readthedocs.io 
# This exercise is based on FLORIS version 2.2.4




# =============================================================================

# Load the modules

import matplotlib.pyplot as plt
import floris.tools as wfct
import pandas as pd
import numpy as np
import seaborn as sns

# =============================================================================

## Exercise 1 ##

# Load the input file
fi = wfct.floris_interface.FlorisInterface("example_input.json")

# Task a) How to set the turbine coordinates to get the location of turbine as Figure 1? Afterwards, try to plot the same graph

D = fi.floris.farm.turbines[0].rotor_diameter

layout_x = [0, 7*D, 0, 7*D]
layout_y = [0, 0, 5*D, 5*D]

# To plot the graph, check the visualize_layout function floris.tools.layout_functions.visualize_layout
turbineLoc = pd.DataFrame({'x': layout_x, 'y': layout_y})
wfct.layout_functions.visualize_layout(turbineLoc,D,show_wake_lines=True)

# =============================================================================

## Exercise 2 ##

# Task a) Calculate the wake and subsequently the generated power by the wind farm and by each turbine

fi.reinitialize_flow_field(layout_array=[layout_x, layout_y])
fi.calculate_wake()
power_array = fi.get_turbine_power()

power_turb_i0 = power_array[0]
power_turb_i1 = power_array[1]
power_turb_i2 = power_array[2]
power_turb_i3 = power_array[3]

power_initial = np.sum(power_array)

print('Initial wind farm power is =', power_initial)

#  Task b) Calculate the axial induction factor of each turbine

aI_turb_i0 = fi.floris.farm.turbines[0].aI
aI_turb_i1 = fi.floris.farm.turbines[1].aI
aI_turb_i2 = fi.floris.farm.turbines[2].aI
aI_turb_i3 = fi.floris.farm.turbines[3].aI
aI = [aI_turb_i0,aI_turb_i1,aI_turb_i2,aI_turb_i3]

for i in range(len(aI)):
    print('Axial induction factor of turbine', i, '=', aI[i])

#  Task c) Plot the flow field

hor_plane = fi.get_hor_plane()
wfct.visualization.visualize_cut_plane(hor_plane)

# =============================================================================

## Exercise 3 ##

# Task a) Find the optimal yaw angle setting

min_yaw = 0.0
max_yaw = 25.0


yaw_opt = wfct.optimization.scipy.yaw.YawOptimization(fi,
                                                      minimum_yaw_angle=min_yaw,
                                                      maximum_yaw_angle=max_yaw)
yaw_angles = yaw_opt.optimize()


for i in range(len(yaw_angles)):
    print('Turbine ', i, '=', yaw_angles[i], ' deg')

# Task b) Calculate the wake for the new assigned optimal yaw angles
    
fi.calculate_wake(yaw_angles=yaw_angles)

# Task c) Calculate the generated power for the optimized scenario. What is the power percentage gained?

power_opt = np.sum(fi.get_turbine_power())

print('power_opt =', power_opt)
print('power_opt =', power_initial)

print('Total Power Gain = %.4f%%' %
      (100.*(power_opt - power_initial)/power_initial))

# Task d) Calculate the generated power for the optimized scenario. What is the power percentage gained?

hor_plane = fi.get_hor_plane()
wfct.visualization.visualize_cut_plane(hor_plane)

# =============================================================================

## Exercise 4 ##   

# Task a) Calculate the power for the default and optimized yaw settings for wind directions from 0 to 350 degrees with equally spaced intervals of 10 degrees for a fixed wind speed of 8 m/s. 
#         Store in arrays all the data utilized as well as the results - including each optimized yaw -
wind_speed = 8 
wind_direction = np.linspace(0,350,36)

wind_direction_ar = np.array([])
power_initial_ar =  np.array([])
power_opt_ar =  np.array([])
yaw_opt_ar_i0 =  np.array([])
yaw_opt_ar_i1 =  np.array([])
yaw_opt_ar_i2 =  np.array([])
yaw_opt_ar_i3 =  np.array([])

for i in range(0, len(wind_direction)):        
        fi.reinitialize_flow_field(layout_array=(layout_x, layout_y), wind_direction=wind_direction[i])
        fi.calculate_wake(yaw_angles=0)
        wind_direction_ar = np.append(wind_direction_ar, wind_direction[i])
        power_initial = np.sum(fi.get_turbine_power())
        power_initial_ar = np.append(power_initial_ar, power_initial)

        yaw_opt = wfct.optimization.scipy.yaw.YawOptimization(fi, 
                                                              minimum_yaw_angle=min_yaw,
                                                              maximum_yaw_angle=max_yaw)
        yaw_angles = yaw_opt.optimize()
        yaw_opt_ar_i0 = np.append(yaw_opt_ar_i0, yaw_angles[0])
        yaw_opt_ar_i1 = np.append(yaw_opt_ar_i1, yaw_angles[1])
        yaw_opt_ar_i2 = np.append(yaw_opt_ar_i2, yaw_angles[2])
        yaw_opt_ar_i3 = np.append(yaw_opt_ar_i3, yaw_angles[3])
        fi.calculate_wake(yaw_angles=yaw_angles)        
        power_opt = np.sum(fi.get_turbine_power())
        power_opt_ar = np.append(power_opt_ar, power_opt)   

# Task b) Create a dataframe comprising the optimized yaw of each turbine, the initial power and the optimized power for each wind direction

percentual_gain = 100*(power_opt_ar - power_initial_ar)/power_initial_ar        
df_obs = pd.DataFrame(np.array([wind_direction_ar, yaw_opt_ar_i0, yaw_opt_ar_i1, yaw_opt_ar_i2, yaw_opt_ar_i3, power_initial_ar, power_opt_ar,percentual_gain])).T 
df_obs.columns = ['wind direction [deg]','yaw_i0 [deg]', 'yaw_i1 [deg]', 'yaw_i2[deg]', 'yaw_i3[deg]', 'initial power [W]', 'optimized power [W]', 'gain [%]']
    

# Task c) At last, plot a graph of the power gain over each wind direction

fig = plt.figure()
fig.suptitle('Percentage gain for each wind direction')
sns.lineplot( x= 'wind direction [deg]', y = 'gain [%]', data = df_obs, marker ='o', label = '{} m/s'.format(8)) 
plt.xticks(np.arange(0,350,step = 30))
plt.ylabel('Power Gain [%]')
plt.xlabel('Wind Direction [deg]')  
plt.show()

