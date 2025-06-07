%% 準備------------------------------------------------------
%おまじない
clc
clear variables
close all
addpath("subfunctions\")

%データの読み込み
filename_analysis = "";%データ名が決まっている場合入力
if filename_analysis == ""
    filename_analysis = input("入力ファイルの名前:","s");
end

data  =readmatrix(filename_analysis);
data(isnan(data)) = 0;%NaNを0に置き換え
n = data(1,1);                  %ジョイントの数
data_joint = data(2:n+1,:);     %ジョイントの情報(固定位置x,固定位置y，固定か？，原動節か？)
data_link  = data(n+2:end,1:3); %各棒の情報(点1,点2,長さ)

%各種行列などの作成
G = MakeAdjacencyMat(data_link,n);            %リンクの隣接行列
is_positioned = zeros(3,n); %(row1)点の位置が定まっているか,(row2,3)隣接している点で定まっているものはあるか
que = [];                                   %探索のキュー
global result %解析手順結果をまとめるテーブル
result = table('Size',[n 7],'VariableTypes',['double',"double",'string','double','double','double','double']);
result.Properties.VariableNames = ["JointNumber","Analysis_Order","Analysis_Method","Joint1","Joint2","input1","input2"];
result.JointNumber = transpose(1:n);
[barnum,~] = size(data_link);%リンクの数

J = struct();   %各点の情報をまとめる構造体．位置，速度，加速度など．
for i = 1:n
    J(i).x = data_joint(i,1);
    J(i).y = data_joint(i,2);
end

%% 解析手順の決定------------------------------------------------------------------
%固定点の処理
for i=1:n
    %固定点かどうかの情報はdata_jointの三列目にある．(0->動く，1->固定点),
    if data_joint(i,3)
        result.Analysis_Method(i) = "Fixed Point";
        %固定座標をinpu1,2に
        result.input1(i) = data_joint(i,1);
        result.input2(i) = data_joint(i,2); 
        [que,is_positioned] = after_positioned(i,que,is_positioned,G,data_joint);%点決定後の後処理
    end
end

%一点から定まる場合(crank_input)は都度処理している
%あとは，隣接する二点から定まる場合(RRR_links,coupler_point)について考えていけばいい
%隣接する二点が定まったものからqueに入れていく->これはafter_positioned内で行う
%そしてその二点から定めるようにすれば無駄な組み合わせを考える必要がない

%queの赴くまま探索
while que
    %queから探索する値を取り出してそれをqueから削除
    search_num = que(1);
    que(:,1) = [];
    index1 = is_positioned(2,search_num);
    index2 = is_positioned(3,search_num);
    if G(index1,index2) %search_numに隣接していて位置の分かっている二点同士が直接つながっている
        %節上の点
        result.Analysis_Method(search_num) = "Coupler_Point";
        result.Joint1(search_num) = index1;
        result.Joint2(search_num) = index2;
        %result.L1(search_num) = index1;
        %result.L2(search_num) = index2;
        [que, is_positioned] = after_positioned(search_num,que,is_positioned,G,data_joint);
    else 
        %RRR links
        result.Analysis_Method(search_num) = "RRR_Links";
        result.Joint1(search_num) = index1;
        result.Joint2(search_num) = index2;
        %result.L1(search_num) = index1;
        %result.L2(search_num) = index2;
        [que, is_positioned] = after_positioned(search_num,que,is_positioned,G,data_joint);
    end
end

%探索が終わったのに全部の点が分かっていない場合
if find(~is_positioned(1,:))
    disp("エラー！点が定まりません．入力データを確認してください")
    return
end
disp("解析順が決定しました")


%% 相対位置の決定準備----------------------------------------------------------------------
%RRR_linksとcoupler_pointの数の和=m
%2^m乗だけある選択肢から，リンク同士が交差しないものを抽出
%矛盾が起きない(位置の任意性がある)のは，繋がる点が2つの場合
%そのときの組み合わせから適切なものをユーザに選択してもらう

%RRR_linksとCoupler_pointの抽出
RorC = or(result.Analysis_Method=="RRR_Links",result.Analysis_Method=="Coupler_Point");
RorC_index = find(RorC);%RRR_linksかCoupler_Pointのジョイントのindex
m = length(RorC_index);%RRR_linksかCoupler_Pointのジョイントの数
result_for_search = sortrows(result,2);%Analysis_order順に並べたもの
RorC_ordersorted = or(result.Analysis_Method=="RRR_Links",result.Analysis_Method=="Coupler_Point");
RorC_index_ordersorted = find(RorC);%sortされた状態でのインデックス

%各種変数や行列の定義
t = tic();
fignum= 1;              %figureの数              
figure(1);              
plotinfig=1;            %figure内のプロットの数
plotinfig_max=16;       %一つのfigureに表示するplot数の最大値
theta_arr = data_joint(data_joint(:,4) ~= 0,5);%クランクからの入力角
maxstep = max(result.Analysis_Order);%解析の最大ステップ
candidacy_num = 1;                       %候補の番号
candidacy_max = 100;                 %候補の最大数（適当）
candidacy = zeros(candidacy_max,m);   %候補を格納する配列   

%ある順番jの点の位置が定まったときにすでに定義されているリンクの集合を作っておく
link_j = cell(barnum,maxstep+1);   
link_j_new = cell(barnum,maxstep);%ある順番jの点の位置が定まったときに初めて定義できるリンクの集合,最終列はdummy
%交差チェックはlink_j内のとlink_j_new内のを調べればOK

%ここら辺絶対もっとキレイにかけるけどとりあえずよしとする
for j=2:maxstep+1
    rj = 1;%link_jに書き込む行番号
    rjn = 1;
    former_positioned = result.JointNumber(result.Analysis_Order==j-1);
    positioned_points = result.JointNumber(result.Analysis_Order<j);%jまでで位置が分かっている点の集合 
    %リンクがpositioned_pointsだけで構成されるかチェック->OKならlink_jに追加
    for ilink=1:barnum %各リンクについてチェック
        if ismember(data_link(ilink,1),positioned_points) && ismember(data_link(ilink,2),positioned_points) 
            link_j{rj,j} = [data_link(ilink,1),data_link(ilink,2)];
            rj = rj+1;
        end
    end
    for ilink=1:barnum
        %link_j_newのj-1番目の更新
        %j列目のリンクのうち，j-1で定められた番号を含むリンクをもってくればよい
        link = link_j{ilink,j};
        if isempty(link)
            continue 
        end
        if link(1,1) == former_positioned || link(1,2) == former_positioned
            link_j_new{rjn,j-1} = link;
            rjn = rjn+1;
        end
    end
end 

%% 相対位置の探索--------------------------------------------
binary_arr = zeros(1,m);
disp("相対位置の決定をします")
fprintf("imax = 2^%d = %d\n",m,2^m)
while length(binary_arr) <= m
    %order順にinput1が入力されるようにする
    pmrow = binary_arr*2-1; %i番目に対応する組み合わせ.2倍して1引くことで0->-1,1->1に変換
    result_tmp = sortrows(result,"Analysis_Order");
    result_tmp.input1(RorC_index_ordersorted) =  pmrow;
    result = sortrows(result_tmp,"JointNumber");

    %最初の計算
    J = calc_position(result,J,theta_arr,0,1,G);
    count = 0;%どこの階層で交差が発生したかを記録する->iの次の値を決めるのに使う

    for order = 1:maxstep
        %解析手順に則った解析の実行と交差のチェック
        method = result.Analysis_Method(result.Analysis_Order == order);
        J = calc_position(result,J,theta_arr,order-1,order,G);
        if method == "RRR_Links"||method == "Coupler_Point"
            count = count+1;
        end

        %交差のチェックはlink_jのorder列目の要素とlink_j_newのorder列目の要素同士ですればよい
        isOK = 1;
        linkdata_order = cell2mat(link_j(:,order)) ;      %order番目までで定義済みのリンク
        linkdata_order_new = cell2mat(link_j_new(:,order)); %order番目で定義されるリンク
        for il1 = 1:height(linkdata_order)
            Pa = linkdata_order(il1,1);
            Pb = linkdata_order(il1,2);
            for il2 = 1:height(linkdata_order_new)
                Pc = linkdata_order_new(il2,1);
                Pd = linkdata_order_new(il2,2);
                %線分PaPbと線分PcPdの交差をチェック(点が一致する場合は交差判定されない)
                %一つでも交差する組み合わせがあればisOK->0になる
                isOK = isOK*~is_crossing(J(Pa).x,J(Pa).y,J(Pb).x,J(Pb).y,J(Pc).x,J(Pc).y,J(Pd).x,J(Pd).y);
                if isOK == 0
                    break%il2のループを抜ける
                end
            end
            if isOK == 0
                break%il1のループを抜ける
            end
        end
        if isOK == 0
            break%orderのループを抜ける
        end
    end

    if isOK == 0
        binary_arr = binary_array_add(binary_arr,MakeBinaryArray(m,m-count));%枝狩り 2^(m-count)を足すのに等しいことしてる
        continue%iの次のループに行く
    end

    fprintf("i=%d:OK\n",BinaryArr2dec(binary_arr))

    %結果の表示
    if plotinfig > plotinfig_max
        fignum = fignum+1;
        figure(fignum);
        plotinfig=1;
    end
    nexttile
    hold on
    for il =1:barnum%各リンクの表示
        p1 = data_link(il,1);
        p2 = data_link(il,2);
        plot([real(J(p1).x) real(J(p2).x)],[real(J(p1).y) real(J(p2).y)],"o-")
    end
    if candidacy_num > candidacy_max    
        candidacy = [candidacy;pmrow];%候補が多すぎたら配列に追加していく
    end

    candidacy(candidacy_num,:) = pmrow;
    title(candidacy_num)
    plotinfig = plotinfig+1;
    candidacy_num = candidacy_num + 1;
    binary_arr = binary_array_add(binary_arr,MakeBinaryArray(m,0)); %1を足すのに等しいことをしている
end
toc(t)
%候補からの選定
if candidacy_num == 1%有効な候補が見つからなかった
    disp("有効な組み合わせが見つかりません")
    disp("入力データを見直すか，自分でresultを編集してください")
    result_for_search.input1(RorC_index_ordersorted) = candidacy(1,:)';
    close all
else
    num = input("適切なリンク機構の番号を入力:");
    result_for_search.input1(RorC_index_ordersorted) = candidacy(num,:)';
    close all
end

result = sortrows(result_for_search,1);

%% 結果の表示-------------------------------------------------------
disp("解析手順の結果:")
disp(result)
filename_write = "result_" + filename_analysis;
writetable(result,filename_write);
dispstr = sprintf("解析手順の結果を「%s」に保存しました",filename_write);
disp(dispstr)
