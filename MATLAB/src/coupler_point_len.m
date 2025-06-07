function [Xc_p,Yc_p,Xc_m,Yc_m] = coupler_point_len(X0,Y0,X1,Y1,L0,L1,L2)
%節上の点の位置座標を求める際，基準からの座標ではなく二点からの距離を使う
%上側か下側の両方ありうるので注意
%L0=J0J1, L1=J0J ,L2=J2J 
xc = (L0^2+L1^2-L2^2)/(2*L0);
yc_p = sqrt(L1^2-xc^2);
yc_m = -yc_p;

phi = link_angle(X0,Y0,X1,Y1);
Xc_p = xc.*cos(phi) - yc_p.*sin(phi) + X0;
Yc_p = xc.*sin(phi) + yc_p.*cos(phi) + Y0;
Xc_m = xc.*cos(phi) - yc_m.*sin(phi) + X0;
Yc_m = xc.*sin(phi) + yc_m.*cos(phi) + Y0;


end

