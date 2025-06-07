function [que, is_positioned] = after_positioned(positioned_num,que,is_positioned,G,data_joint)
%AFTER_POSITIONED
global result
    %is_positionedの更新
    is_positioned(1,positioned_num) = 1;%一行目
    %位置が決まった点に隣接する点のうち位置が定まっていないもののis_positonedを更新
    adjacent_joint = find(G(positioned_num,:));%positioned_numに隣接する点を取り出す
    for i = 1:length(adjacent_joint)
        if is_positioned(1,adjacent_joint(i)) == 0  %まだ位置が定まっていない点のみ考えればよい
            if is_positioned(2,adjacent_joint(i)) == 0
                is_positioned(2,adjacent_joint(i)) = positioned_num;
            %3行目にデータがなく，追加しようとするデータが二行目とは異なれば追加
            elseif (is_positioned(2,adjacent_joint(i)) ~= positioned_num) && (is_positioned(3,adjacent_joint(i)) == 0)
                is_positioned(3,adjacent_joint(i)) = positioned_num;
                %ここにデータが入ったということはその点はもう位置が定まるということ．queに追加．
                que = [que, adjacent_joint(i)];
            end
        end
    end

    %固定点でなければ解析順番更新
    if data_joint(positioned_num,3) == 0
        result.Analysis_Order(positioned_num) = max(result.Analysis_Order)+1;
    end

    %positioned_numが原動節の場合すぐに次の点を定め,再度後処理
    if data_joint(positioned_num,4) 
       crank_num = positioned_num;%今決まった点が次のクランクの起点
       positioned_num = data_joint(crank_num,4);
       result.Analysis_Method(positioned_num) = "Crank_input";
       result.Joint1(positioned_num) = crank_num;
       %result.L1(positioned_num) =crank_num;
       %固定原動節でない場合，crank_numの姿勢角を求めるための点がresultのJ2に来る
       if data_joint(crank_num,3) == 0
          result.Joint2(positioned_num) = is_positioned(2,crank_num);
          %姿勢phi = link_angle(J2.x,J2.y,J1.x,J2.y)
       end

       [que, is_positioned] =  after_positioned(positioned_num,que,is_positioned,G,data_joint);
    end
end

