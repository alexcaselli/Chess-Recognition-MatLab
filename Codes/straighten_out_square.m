function result = straighten_out_square(image, photo)

%ruoto l'immagine in modo che non ci siano linee perfettamente verticali
%che Hough non è in grado di individuare
image = imrotate(image, 15);


%trovo gli edge dell'immagine con canny
ime = edge(image, 'canny', [], 1);


%utilizzo Hough per trovare le linee
[H, T, R] = hough(ime, 'RhoResolution', 3, 'Theta', -90:1:89);

%prendo solo le 4 linee della scacchiera
coords = houghpeaks(H, 4);
rhos   = R(coords(:, 1));
thetas = T(coords(:, 2));
thetas = thetas*pi/180;

%salvo le dimensioni dell'immagine degli edge
[rows, cols] = size(ime);

%trovo le intersezioni tra le linee in modo da ottenere le coordinate degli
%angoli della scacchiera
XY=find_intersection_points(rhos, thetas, rows, cols);

%salvo le coordinate in un formato consono alla funzione successiva
mm = [XY(1, 1) XY(1, 2) XY(2, 1) XY(2, 2) XY(3, 1) XY(3, 2) XY(4, 1) XY(4, 2)];

%converto image in double perchè è in realtà composta da valori logici
%inserisco un poligono di quattro lati nell'immagine in modo che la
%maschera abbia gli angoli corretti e non tagliati dalle operazioni
%morfologici precendenti
maskp = insertShape(im2double(image), 'FilledPolygon', mm, ...
    'Color',  'white', 'Opacity', 1);


%dichiaro un elemento strutturante
strut = strel('square', 1);

%trovo l'angolazione della scacchiera rispetto all'asse orizzontale e la
%raddrizzo (notare che le immagini non possono avere un'angolazione < di
%-45 o superiore a 45 con l'asse orizzontale)
barAngle = find_angle(ime);



%leggo l'immagine originale e la converto in un'immagine a livelli di
%grigio con valori tra 0 e 1
gy = rgb2gray(im2double(photo)); %probabilmente andrà binarizzata

%scalo l'immagine
gy = find_scale(gy);

%ruoto l'immagine di 15° come fatto inizialmente
gy = imrotate(gy, 15);


%combino gy con il secondo canale della maschera contenente la shape
%inserita
gy = gy .* maskp(:, :, 2);



%raddrizzo gy con l'angolo trovato precedentemente
res = imrotate(gy, barAngle, 'bilinear', 'crop');



%ruoto anche la maschera in modo da renderla nuovamente componibile
image = imrotate(maskp, barAngle, 'bilinear', 'crop');



%erodo la maschera per renderla più precisa
maskp = imerode(image, strut);


%trovo le coordinate dei punti dopo la rotazione
point = rotate_points(mm, maskp, barAngle);


%uso la boundingbox per trovare la forma corretta della scacchiera
fixedPoints = get_fixedpoints(maskp(:, :, 2));


%stabilisce la correzzione prospettica usando come punti di partenza quelli
%trovati precedentemente
tform = fitgeotrans(point, fixedPoints, 'projective');

%applica la correzione prospettica defunita da tform
A = imwarp(res, tform);


%restituisco il risultato
result = A;
end