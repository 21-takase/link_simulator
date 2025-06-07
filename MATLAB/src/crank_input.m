function [X1,Y1] = crank_input(L,X0,Y0,phi,theta)
%phi[rad]:姿勢
%theta[rad]:原動節の入力
%L[m]:リンクの長さ
%CRANK_INPUT この関数の概要をここに記述
X1 = L*cos(theta+phi) + X0;
Y1 = L*sin(theta+phi) + Y0;
end

