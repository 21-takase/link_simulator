function [X,Y,Z] = MakeCoordinateData(x,y,dt,tstop,vlift,L0,L1,L2,vmax_i,omegamax)
%x,y:点のデータ
%dt:tの刻み幅
%tstop:ステージの上げ下げのために止まる時間
%maxv:ある軸方向の最大速度
    imax = height(x);
    X_raw = [];
    Y_raw = [];
    %上げ下げのタイミングを与える配列
    stagemove = zeros(1,imax);
    %0でない部分のみ取り出す(y基準)
    for i = 1:imax
        xi = x(i,y(i,:) ~= 0);
        yi = y(i,y(i,:) ~= 0);
        %点を追加する
        X_raw = [X_raw xi];
        Y_raw = [Y_raw yi];
        stagemove(i) = length(X_raw);    
    end
    
    X = [X_raw(1)];
    Y = [Y_raw(1)];
    
    Z_down = -tstop*vlift;
    Z = [0];
    count = 1;

    %vmax以下になるようにX_rawからX,Y_rawからYを作っていく
    for k = 2:length(X_raw)
        vxk = (X_raw(k) - X_raw(k-1)) / dt;
        vyk = (Y_raw(k) - Y_raw(k-1)) / dt;
        [maxVx,maxVy] = CalcMaxV(L0,L1,L2,X_raw(k-1),Y_raw(k-1),sign(vxk)*vmax_i, sign(vyk)*vmax_i,omegamax);
        
        if maxVx == 0 || maxVy == 0
            vmax = max(abs(maxVx),abs(maxVy));
        else
            vmax = min(abs(maxVx),abs(maxVy));
        end

        if vmax == 0 
            X = [X X_raw(k)];
            Y = [Y Y_raw(k)];
            Z = [Z 0];
            continue
        end
        delta = vmax*dt;
        if  (abs(vxk) >= vmax) && (abs(vxk) > abs(vyk))
            n = ceil(abs((X_raw(k) - X_raw(k-1)) / delta));
            X_interpolation = linspace(X_raw(k-1)+sign(vxk)*delta,X_raw(k),n);
            Y_interpolation = linspace(Y_raw(k-1)+sign(vyk)*delta,Y_raw(k),n);
            Z_interpolation = zeros(1,n);
        elseif abs(vyk) >= vmax
            n = ceil(abs((Y_raw(k) - Y_raw(k-1)) / delta));
            X_interpolation = linspace(X_raw(k-1)+sign(vxk)*delta,X_raw(k),n);
            Y_interpolation = linspace(Y_raw(k-1)+sign(vyk)*delta,Y_raw(k),n);
            Z_interpolation = zeros(1,n);
        else
            X = [X X_raw(k)];
            Y = [Y Y_raw(k)];
            Z = [Z,0];
            continue;
        end
        %移動のタイミングの場合，それにかかる時間だけ止めるデータを作る
        if k-1 == stagemove(count)
            N_stop = ceil(tstop/dt);
            X_stop_beforemove = X_raw(k-1)*ones(1,N_stop);
            X_stop_aftermove  = X_raw(k)*ones(1,N_stop);
            Y_stop_beforemove = Y_raw(k-1)*ones(1,N_stop);
            Y_stop_aftermove  = Y_raw(k)*ones(1,N_stop);
            Z_down_beforemove = linspace(0,Z_down,N_stop);
            Z_up_aftermove    = linspace(Z_down,0,N_stop);
            
            X_interpolation = [X_stop_beforemove, X_interpolation, X_stop_aftermove];
            Y_interpolation = [Y_stop_beforemove, Y_interpolation, Y_stop_aftermove];
            Z_interpolation = [Z_down_beforemove, Z_down*ones(1,n),Z_up_aftermove];

            count = count+1;
        end
        X = [X X_interpolation];
        Y = [Y Y_interpolation]; 
        Z = [Z Z_interpolation];

    end
end


