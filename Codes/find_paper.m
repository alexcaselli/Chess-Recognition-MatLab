function r = find_paper(image)

%correggo il WB con white patch
illuminant_wp2 = illumwhite(image);
B_wp2 = chromadapt(image, illuminant_wp2);


%porto l'immagine in hsv
imh = rgb2hsv(B_wp2);

%estrapolo i canali
s = imh(:, :, 2).* 1.5;
v = imh(:, :, 3).* 1.5;

%correggo la gamma dei canali s e v
s = imadjust(s, [0.3 0.6], []);
v = imadjust(v, [0.3 0.6], []);

%soglio i 2 canali
s = s < 0.15;
v = v > 0.91;

%porto l'immagine con WB corretto in scala di grigi
img = rgb2gray(B_wp2);

%gamma correction
J = imadjust(img, stretchlim(img), []);

%figure; imshow(J);title('gamma correction');
imc = imadjust(J, [0.2 0.8], []);

%binarizzo con algoritmo sauvola
BW = sauvola(imc, [500 500]);

%unico le tre maschere
final = and(and(s, v), BW);

%creo 3 elementi strutturanti
se = strel('disk', 15);
so = strel('disk', 9);


%morfologia matematica per sistemare la maschera (chiudo buchi e correggo
%imperfezioni)
closedd = imclose(final, se);

r = imopen(closedd, so);

end
