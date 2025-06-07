function J = calc_position(analysis_arr,J,theta_arr,order_start,order_end,G)
    %theta_arr->原動節の入力角を各行に並べたもの
    crank_num = 1;%原動節の入力角を決めるindex
    if order_start==0 
        order_start =1; 
    end
    for k=order_start:order_end
        jn = find(analysis_arr.Analysis_Order==k);%今決める点の番号
        switch analysis_arr.Analysis_Method(jn)
            case "Crank_input"
                index1 = analysis_arr.Joint1(jn);%原動節の番号
                index2 = analysis_arr.Joint2(jn);%原動節が繋がっている点の番号(あれば)
                %固定原動節によるcrank_inputでない場合(index2が0でない場合),入力角phiを計算
                if index2
                    phi = link_angle(J(index2).x,J(index2).y,J(index1).x,J(index2).y);
                else
                    phi=0;
                end
                L = G(index1,jn);
                theta = theta_arr(crank_num,:);
                crank_num = crank_num+1;
                [J(jn).x ,J(jn).y] = crank_input(L,J(index1).x,J(index1).y,phi,theta);
            case "RRR_Links"
                index1 = analysis_arr.Joint1(jn);
                index2 = analysis_arr.Joint2(jn);
                L1 = G(jn,index1);
                L2 = G(jn,index2);
                if analysis_arr.input1(jn) == 1%上側
                    [J(jn).x,J(jn).y] = RRR_links(J(index1).x,J(index1).y,J(index2).x,J(index2).y,L1,L2);
                elseif analysis_arr.input1(jn) == -1 %下側
                    [~,~,J(jn).x,J(jn).y] = RRR_links(J(index1).x,J(index1).y,J(index2).x,J(index2).y,G(jn,index1),G(jn,index2));
                end
            case "Coupler_Point"
                index1 = analysis_arr.Joint1(jn);
                index2 = analysis_arr.Joint2(jn);
                L0 = G(index1,index2);
                L1 = G(jn,index1);
                L2 = G(jn,index2);
                if analysis_arr.input1(jn) == 1%上側
                    [J(jn).x,J(jn).y] = coupler_point_len(J(index1).x,J(index1).y,J(index2).x,J(index2).y,L0,L1,L2);
                elseif  analysis_arr.input1(jn) == -1                   %下側
                    [~,~,J(jn).x,J(jn).y] = coupler_point_len(J(index1).x,J(index1).y,J(index2).x,J(index2).y,L0,L1,L2);
                end
            otherwise
                disp("エラー！！解析手順が定まっていません")
        end
    end
end

