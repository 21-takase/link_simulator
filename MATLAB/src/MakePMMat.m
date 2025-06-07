function pmMat = MakePMMat(m)
%MAKEPMMAT 2^m x m行の-1,1の組み合わせの行列を返す

pmMat = zeros(2^m,m);%i行目はiを二進表現したもの(-1->0)

%i行目はi-1を二進表現したもの(-1->0)
for i =0:2^m-1
    ii = i;%計算用のiのコピー
    for j=1:m
        b = mod(ii,2);
        %0->-1,1->1になるように変換
        c = 2*b-1;
        pmMat(i+1,m+1-j) = c;
        ii = (ii-b)/2;
    end
end

