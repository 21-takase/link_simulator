function pmRow = MakePMRow(m,row)
%MAKEPMROW 2^m x m行の-1,1の組み合わせの行列のうち，row行目を返す
%row行目はrow-1の二進表現に対応する(-1=>0,1=>1)

pmRow = zeros(1,m);%i行目はiを二進表現したもの(-1->0)

i = row-1;

for j=1:m
    b = mod(i,2);
    %0->-1,1->1になるように変換
    c = 2*b-1;
    pmRow(1,m+1-j) = c;
    i = (i-b)/2;
end


