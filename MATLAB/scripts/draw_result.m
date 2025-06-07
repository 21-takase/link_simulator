clc
clear variables
close all
addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'src'));

%時間
dt=0.005;
t=0:dt:5;
sz = size(t);

%theta[rad]
theta = 2*pi*t;

%解析データの読み込み
filename_link = "theo_jansen.csv";%データ名が決まっている場合入力
if filename_link == ""
    filename_link = input("入力ファイルの名前:","s");
end

data_folder = fullfile(fileparts(mfilename('fullpath')), '..', 'data');
filename_analysis = "result_"+filename_link;
fullpath_anlaysis = fullfile(data_folder, filename_analysis);
fullpath_data = fullfile(data_folder, filename_link);

analysis_arr = readtable(fullpath_anlaysis);
analysis_arr.Analysis_Method = string(analysis_arr.Analysis_Method);
[n,~] = size(analysis_arr);
data = readmatrix(fullpath_data);
linkdata = data(n+2:end,1:3);
G = MakeAdjacencyMat(linkdata,n);
barset = linkdata(:,1:2);

%結果をまとめる配列J
J = struct();   %各点の情報をまとめる構造体．位置，速度，加速度など．
%位置の初期化
for i = 1:n
    J(i).t = t;
    if analysis_arr.Analysis_Method(i) == "Fixed Point"
        J(i).x = analysis_arr.input1(i)*ones(sz);
        J(i).y = analysis_arr.input2(i)*ones(sz);
    else
      J(i).x = zeros(sz);
      J(i).y = zeros(sz);
    end
end

%計算
J = calc_position(analysis_arr,J,theta,1,max(analysis_arr.Analysis_Order),G);
%描画範囲の決定
min_and_max = zeros(n,4);%[xmin,xmax,ymin,ymax] 
for i =1:n
    min_and_max(i,1) = min(J(i).x);
    min_and_max(i,2) = max(J(i).x);
    min_and_max(i,3) = min(J(i).y);
    min_and_max(i,4) = max(J(i).y);
end
xmin = min(min_and_max(:,1));
xmax = max(min_and_max(:,2));
ymin = min(min_and_max(:,3));
ymax = max(min_and_max(:,4));
xrange = xmax-xmin;
yrange = ymax-ymin;
margin=0.05;
axislimit = [xmin-xrange*margin,xmax+xrange*margin,ymin-yrange*margin,ymax+yrange*margin];

%minx = min(J.x)
%maxx = max(J(1).x)
%animation
animation = figure(1);
hold on
axis(axislimit)
grid on
pbaspect([xrange yrange 1])
h = animatedline("Color",'b');%trajectory用オブジェクト


%points
for i = 1:n
    J(i).pplot = plot(J(i).x(1),J(i).y(1),"o");
end

%links
barnum = height(linkdata);    %棒の数
bars = line(barnum,1).empty;%棒のline objectを格納する配列
for i = 1:barnum        
    bari1 = linkdata(i,1);
    bari2 = linkdata(i,2);
    bars(1,i) = plot([J(bari1).x(1), J(bari2).x(1)], [J(bari1).y(1),J(bari2).y(1)]);
end

%main loop of animation
for k = 2:length(t)
    %update positions of joints
    for i = 1:n
        J(i).pplot.XData = J(i).x(k);
        J(i).pplot.YData = J(i).y(k);
    end
    %update bar
    for i = 1:barnum
        bars(1,i).XData = [J(linkdata(i,1)).x(k),J(linkdata(i,2)).x(k)];
        bars(1,i).YData = [J(linkdata(i,1)).y(k),J(linkdata(i,2)).y(k)]; 
    end
    %update Trajectory
    addpoints(h,J(n).x(k),J(n).y(k))
    titletext = "t=" + num2str(round(t(k),1)) + "s";
    title(titletext)
    drawnow limitrate
end
drawnow

% リンク先端のx, yを時間に対してプロット
figure;
subplot(2,1,1);
set(gca, 'FontSize', 18);
plot(t, J(n).x, 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('X position');
title(sprintf('Joint %d X Position over Time', n));
grid on;

subplot(2,1,2);
set(gca, 'FontSize', 18);
plot(t, J(n).y, 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Y position');
title(sprintf('Joint %d Y Position over Time', n));
grid on;