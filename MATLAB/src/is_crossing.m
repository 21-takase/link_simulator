function is_crossing = is_crossing(xa,ya,xb,yb,xc,yc,xd,yd)
%線分ABと線分CDが交差する場合1,交差しないとき0を返す
s1 = (xa-xb)*(yc-ya) - (ya-yb)*(xc-xa);
t1 = (xa-xb)*(yd-ya) - (ya-yb)*(xd-xa);

s2 = (xc-xd)*(ya-yc) - (yc-yd)*(xa-xc);
t2 = (xc-xd)*(yb-yc) - (yc-yd)*(xb-xc);

is_crossing = (s1*t1)<0 &&(s2*t2)<0;
end

