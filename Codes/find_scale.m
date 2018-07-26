function r = find_scale(image)

[h, w, ~] = size(image);
if (h + w) > 5200
    scale = 0.5;
else
    if (h + w) > 4500
        scale = 0.6;
    else
        scale = 1;
    end
end
r = imresize(image, scale);

end

