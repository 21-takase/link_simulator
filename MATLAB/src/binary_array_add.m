function added_array = binary_array_add(binary_array1,binary_array2)
%BINARY_ARRAY_ADD 配列の各要素が二進数の各桁を表す二つの配列を二進数として足す

%桁を揃える
m1 = length(binary_array1);
m2 = length(binary_array2);
m = max(m1,m2);
added_array = zeros(1,m);
if m1 > m2
    binary_array2 = [zeros(1,m1-m2), binary_array2];
elseif m1 < m2
    binary_array1 = [zeros(1,m2-m1), binary_array1];
end

for digit = 1:m
    i = m+1-digit;%下digit桁のデータはi番目にある
    added_array(i) = added_array(i) + binary_array1(i) + binary_array2(i);
    %繰り上がり
    if added_array(i) >= 2
        added_array(i) = added_array(i)-2;
        %最上位の桁で繰り上がりが発生するなら桁を一つ増やす
        if i == 1
            added_array = [1,added_array];
        else
            added_array(i-1) = 1;
        end
    end
end
end

