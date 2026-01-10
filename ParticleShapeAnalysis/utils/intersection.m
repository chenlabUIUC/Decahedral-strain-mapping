function inter = intersection(w1,w2)
    x = (w2(2)-w1(2)) / (w1(1)-w2(1));
    y = x*w1(1) +w1(2);
    inter = [x,y];
end