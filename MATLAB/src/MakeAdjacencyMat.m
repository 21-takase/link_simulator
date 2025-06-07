function G = MakeAdjacencyMat(linkdata,n)
    %GRAPH この関数の概要をここに記述
    %   詳細説明をここに記述
    [linknum,~] = size(linkdata);
    G = zeros(n,n);
    for i = 1:linknum
        index1 = linkdata(i,1);
        index2 = linkdata(i,2);
        G(index1,index2) = linkdata(i,3);
        G(index2,index1) = linkdata(i,3);    
    end
end

