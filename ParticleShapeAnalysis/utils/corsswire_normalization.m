function out = corsswire_normalization(img)
    img = double(img);
    corsswire = floor(length(img)/2);
    min_value = min([img(corsswire,:)';img(:,corsswire)]);
    img = img-min_value;
    max_value = max([img(corsswire,:)';img(:,corsswire)]);
    out = img/max_value;
end