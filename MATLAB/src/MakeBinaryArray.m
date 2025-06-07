function binary_array = MakeBinaryArray(m,inum)
%MAKEBINARYARRAY 2^inum乗の，m桁の二進表示を各要素にもつ配列を返す

binary_array = zeros(1,m);
binary_array(m-inum) = 1;

end

