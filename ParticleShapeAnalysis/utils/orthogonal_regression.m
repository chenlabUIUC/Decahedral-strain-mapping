function out = orthogonal_regression(D)
    center = mean(D,1);
    D = D-center;
    [coeff,~,~] = pca(D);
    basis = coeff(1:2,:);
    a = basis(2)/basis(1);
    b = center(2)-a*center(1);
    out = [a;b];
end