function insiders = in_which_polygon(point,B)
    insiders = zeros([length(B),1]);
    for i = 1:length(B)
        x = inpolygon(point(1),point(2),B{i}(:,1),B{i}(:,2));
        insiders(i) = x;
    end
end