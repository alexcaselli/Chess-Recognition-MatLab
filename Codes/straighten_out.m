function result = straighten_out(image, photo)
close all;
stats = regionprops('table', image, 'Centroid', ...
    'MajorAxisLength', 'MinorAxisLength');

x = stats.MajorAxisLength;
y = stats.MinorAxisLength;


if ((x/y >= 0.85) && (x/y <= 1.08))
    result = straighten_out_square(image, photo);
else
    result = straighten_out_rectangle(image, photo);
end
end