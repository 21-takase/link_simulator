function [Xc,Yc] = coupler_point(X0,Y0,X1,Y1,xc,yc)
phi = link_angle(X0,Y0,X1,Y1);
Xc = xc.*cos(phi) - yc.*sin(phi) + X0;
Yc = xc.*sin(phi) + yc.*cos(phi) + Y0;
end

