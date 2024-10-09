function u_2 = JensenWakeModel(u_1,k_w,r_r,c_T,x)
    u_2 = u_1*(1 - ( 1 - sqrt(1 - c_T) )/( (1 + k_w*x/r_r)^2 ) ); % needs adjustment
end