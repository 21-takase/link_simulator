function dec_num = BinaryArr2dec(binary_arr)
%BINARYARR2DEC 二進配列から10進の数字を返す
%   詳細説明をここに記述
m = length(binary_arr);%何桁か
dec_num = 0;

for digit=1:m
    %下digit桁の数字を10進数に変換して足していく
    %下digit桁の数字はi番目にアクセスすれば得られる
    i = m+1-digit;
    dec_num = dec_num + binary_arr(i)*2^(digit-1);
end
end

