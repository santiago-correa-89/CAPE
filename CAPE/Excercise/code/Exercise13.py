# -*- coding: utf-8 -*-
"""

@author: Christian Burth, Felipe Novais, Wei Fu, David Schlipf
"""
# Documentation about FLORIS can be found at: https://floris.readthedocs.io
# This exercise is based on FLORIS version 2.4

# Please, remember to adapt everything set as DUMMY_VALUE
DUMMY_VALUE = 8

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

layout_x = [0, 1000, 0, 1000]
layout_y = [0, 0, 1000, 1000]

# To plot the graph, check the visualize_layout function floris.tools.layout_functions.visualize_layout
fi.reinitialize_flow_field(layout_array=[layout_x, layout_y])
turbineLoc = pd.DataFrame({'x': layout_x, 'y': layout_y})
wfct.layout_functions.visualize_layout(turbineLoc, D, show_wake_lines=True)

# =============================================================================

## Exercise 2 ##

# Task a) Calculate the wake and subsequently the generated power by the wind farm and by each turbine

# Before setting the wake, you have to reinitialize the flow field for the layout previously set
# Check example_01_basic_adjustments.py -> Change the farm layout

power_turb_i0 = DUMMY_VALUE
power_turb_i1 = DUMMY_VALUE
power_turb_i2 = DUMMY_VALUE
power_turb_i3 = DUMMY_VALUE

power_initial = np.sum(DUMMY_VALUE)

print('Initial wind farm power is =', power_initial)

#  Task b) Calculate the axial induction factor of each turbine

aI_turb_i0 = DUMMY_VALUE
aI_turb_i1 = DUMMY_VALUE
aI_turb_i2 = DUMMY_VALUE
aI_turb_i3 = DUMMY_VALUE
aI = [aI_turb_i0, aI_turb_i1, aI_turb_i2, aI_turb_i3]

for i in range(len(aI)):
    print('Axial induction factor of turbine', i, '=', aI[i])

# Task c) Calculate and display the turbulence intensity at each turbine
turbulence_intensities = DUMMY_VALUE

# FLORIS automatically computes the turbulence intensities at each turbine.
# Check the floris_interface module.

#  Task d) Plot the flow field

# First, in order to plot the flow field, you must extract the horizontal plane.
# Check the cut_plane module.



# =============================================================================

## Exercise 3 ##
# Task a) Find the optimal yaw angle setting

min_yaw = DUMMY_VALUE
max_yaw = DUMMY_VALUE

# Find the optimal yaw angles for the defined wind conditions
# You may check out "..\floris\examples\optimization\scipy\controls_optimization\optimize_yaw"

yaw_angles_opt = DUMMY_VALUE

# for i in range(len(yaw_angles_opt)):
#     print('Turbine ', i, '=', yaw_angles_opt[i], ' deg')

# Task b) Calculate the wake for the new assigned optimal yaw angles and visualize it


# Task c) Calculate the generated power for the optimized scenario. What is the power percentage gained?

power_initial = DUMMY_VALUE
power_opt = DUMMY_VALUE

print('power_opt =', power_opt)

print('Total Power Gain = %.4f%%' %
      (100. * (power_opt - power_initial) / power_initial))

# =============================================================================

## Exercise 4 ##

# Task a) Calculate the power for the default and optimized yaw settings for wind directions
#         from 0 to 350 degrees with equally spaced intervals of 10 degrees for a fixed wind speed of 8 m/s.
#         Store in arrays all the data utilized as well as the results - including each optimized yaw -

wind_speed = DUMMY_VALUE
wind_direction = DUMMY_VALUE

# Use these arrays to store the results of each loop
wind_direction_ar = np.array([])
power_initial_ar = np.array([])
power_opt_ar = np.array([])
yaw_opt_ar_i0 = np.array([])
yaw_opt_ar_i1 = np.array([])
yaw_opt_ar_i2 = np.array([])
yaw_opt_ar_i3 = np.array([])

# for i in range(0, len(wind_direction)):
#     fi.reinitialize_flow_field(layout_array=(layout_x, layout_y), wind_direction=wind_direction[i])


# Task b) Create a dataframe comprising the optimized yaw of each turbine, the initial power,
#         the optimized power and the power gain in percent for each wind direction.


# Task c) At last, plot a graph of the power gain over each wind direction.


# =============================================================================

plt.show()
