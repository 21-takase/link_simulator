function [Xb_p,Yb_p,Xb_m,Yb_m] = RRR_links(X0,Y0,X1,Y1,L1,L2)

alpha = segment_angle(X0,Y0,X1,Y1);
L = sqrt((X1-X0).^2+(Y1-Y0).^2);
beta = acos((L1^2+L.^2-L2^2)./(2*L1*L));
phi_p = alpha + beta;
phi_m = alpha - beta;

Xb_p = L1*cos(phi_p) + X0;
Yb_p = L1*sin(phi_p) + Y0;
Xb_m = L1*cos(phi_m) + X0;
Yb_m = L1*sin(phi_m) + Y0;

end

