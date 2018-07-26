function fixedPoints = get_fixedpoints(image)

rp = regionprops(image, 'BoundingBox', 'Area');

%le dimensioni della BB sono sfalsate di mezzo pixel circa, correggo
corr = 0.5;
bb = rp.BoundingBox;
top = bb(2) + corr;
left = bb(1) + corr;
width = bb(3) - corr;
height = bb(4) - corr;

%in base a quale misura è la maggiore capisco in che modo è deformata e
%lo correggo
maxi = max(width, height);

if (maxi == width)
    shift = width-height;
    bb = [left top-shift width height+shift];
else
    shift = height - width;
    bb = [left-shift top width+shift height];
end

%grazie alla BoundingBox ottengo i punti con cui correggere la deformazione
%prospettica dell'immagine
fixedPoints = [bb(1) bb(2); bb(3)+bb(1) bb(2); bb(3)+bb(1) bb(2)+bb(4); bb(1) bb(2)+bb(4)];



end
