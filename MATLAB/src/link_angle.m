function [phi] = link_angle(X0,Y0,X1,Y1)
%phi[rad]:姿勢
phi = atan2(Y1-Y0,X1-X0);

end

