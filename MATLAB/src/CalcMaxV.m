function [maxVx,maxVy] = CalcMaxV(L0,L1,L2,X,Y,vxbase,vybase,omegamax)
    %X,Y,長さの情報が分かっているJを使ってx,y方向の最大速度を求める
    %x,yから逆運動学で姿勢角を求める
    %theta1
    l1 =sqrt((X+L0/2).^2+Y.^2);
    alpha1 = acos((L1.^2+l1.^2-L2^2)./(2*L1*l1));
    beta1 = atan2(Y,X+L0/2);
    theta1 = alpha1 + beta1;
    
    %theta2
    l2 = sqrt((X-L0/2).^2+Y.^2);
    alpha2 = atan2(Y,X-L0/2);
    beta2 = acos((L1^2+l2.^2-L2^2)./(2*L1*l2));
    theta2 = alpha2 - beta2;
    
    %Jacobianの計算
    J = Jacobian_fivelinks(L0,L1,L2,theta1,theta2);
    %omegamaxから，各軸速度の最大値が求まる
    % V = J*[omegamax;omegamax];
    % maxVx = V(1);
    % maxVy = V(2);
     

    %vxbaseとvybaseを与えたときのomegaを計算,abs(omega) < omegamaxならOK．だめなら小さくする

    maxVx = vxbase;
    maxVy = vybase;
    omega = J \ [maxVx;maxVy];
    while max(abs(omega)) >= omegamax 
        maxVx = maxVx*0.99;
        maxVy = maxVy*0.99;
        omega = J \ [maxVx;maxVy];
    end
end

