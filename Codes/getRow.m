function res = getRow(im, k)

%leggo le dimensioni dell'immagine
[r, c] = size(im);

%creo un'immagine binaria che rappresenta la maschera
mask = im>0;


%in base alle dimensioni dell'immagine definisco due elementi strutturanti
%ed un valore che verrà usato per la correzzione della boundingbox
if r + c < 800
    sv = strel('line', 100, 90);
    so = strel('line', 100, 0);
    corr = 5;
else
    if r + c < 2000
        sv = strel('line', 300, 90);
        so = strel('line', 300, 0);
        corr = 7;
    else
        sv = strel('line', 300, 90);
        so = strel('line', 300, 0);
        corr = 10;
    end
end



%uso i due elementi struttranti per fare una open dell'immagine in modo da
%eliminare alcune imperfezioni della maschera
mask = imopen(mask, so);
mask = imopen(mask, sv);





%trovo le dimensioni della boundingbox che racchiude la maschera
box= regionprops(mask, 'Area',  'BoundingBox');
bb = box.BoundingBox;


%correggo le dimensioni della bounding box
left = bb(1)+ corr;
top = bb(2) + corr;
width = bb(3)- 2*corr;
height = bb(4) - 2*corr;
bb = [left top width height];

%ritaglio la maschera e l'immagine con le coordinate della BoundingBox in modo da avere
%solo la maschera nell'immagine

mask = imcrop(mask, bb );





im = imcrop(im, bb );



%le combino
BW = mask.*im;



%salvo le nuove dimensioni della maschera
[r, c] = size(mask);


%la schacchiera è composta da 8 righe e 8 colonne, trovo la lunghezza di un
%lato della singola cella
cell = floor((r/8+c/8)/2);

%genero una scacchiera con lato della singola cella della dimensione
%trovata prima e la rendo binaria
I = checkerboard(cell)>0.5;



%definisco un elemento strutturante
se = strel('square', 2);


%LABEL PEZZI BIANCHI

%uso l'elemento strutturante per separare le sigole celle in modo che siano
%cc separate
J = imdilate(I, se);



%faccio il negativo della scacchiera (le celle bianche non avevano valore
%1)
B = 1-J;



%faccio il labeling delle cc
labelw = bwlabel(B);

%imagesc(labelw), axis image, colorbar;
%figure; imshow(B);title('sample');


%LABEL PEZZI NERI

%uso l'elemento strutturante per separare le sigole celle in modo che siano
%cc separate
I = imerode(I, se);




%faccio il labeling delle cc
labelb = bwlabel(I);



%in base al numero di riga richiesto (k) correggo l'indice che utilizzerò
%per andare a selezionare le celle di quella riga

if mod(k, 2) == 1
    colore1 = 1;
    if k == 3
        k=2;
    else
        if k == 5
            k=3;
        else
            if k==7
                k=4;
            end
        end
    end
else
    colore1 = 0;
    k = k/2;
end

%se colore1 è 1 allora la prima cella della riga sarà bianca
if colore1 == 1
    
    l = 1;
    z = 1;
    
    %ciclo sulle colonne
    while l <= 8
        
        BW = mask .* im;
        
        
        %se il numero di colonna è dispari la cella sarà bianca, nera
        %altrimenti
        if mod(l, 2) ~= 0
            
            %ottengo la maschera della cella
            mask1 = (labelw == k);
            
            
            %inserisco nello stack che conterrà il risultato la cella
            %trovata
            res(:, :, z) = get_cellw(BW, mask1);
            
        else
            %ottengo la maschera della cella
            mask1 = (labelb == k);
            
            
            %inserisco nello stack che conterrà il risultato la cella
            %trovata
            res(:, :, z) = get_cellb(BW,  mask1);
            
        end
        
        %incremento gli indici
        z = z + 1;
        k = k + 4;
        l = l + 1;
        
        
    end
    
else
    
    l = 1;
    z = 1;
    
    %ciclo le colonne
    while l <= 8
        BW = mask.*im;
        
        %se il numero di colonna è pari la cella sarà bianca, nera
        %altrimenti
        if mod(l, 2) == 0
            
            %ottengo la maschera della cella
            mask1 = (labelw == k);
            
            %inserisco nello stack che conterrà il risultato la cella
            %trovata
            res(:, :, z) = get_cellw(BW, mask1);
            
        else
            
            %ottengo la maschera della cella
            mask1 = (labelb == k);
            
            %inserisco nello stack che conterrà il risultato la cella
            %trovata
            res(:, :, z) = get_cellb(BW,  mask1);
        end
        
        
        %incremento gli indici
        z = z + 1;
        k = k + 4;
        l = l + 1;
        
        
    end
    
end






end


function respond = get_cellw(image, mask)

%ottengo la sua boundingbox
box= regionprops(mask, 'Area', 'BoundingBox');
bb = box.BoundingBox;

%ritaglio la maschera con la bb
mask = imcrop(mask, bb );



%ritaglio l'immagine con la bb in modo da avere solo la cella
image= imcrop(image, bb );


%leggo le dimensioni di mask1
[n, m] = size(mask);

%croppo di nuovo BW per essere certi che abbia le dimensioni
%corrette
image= imcrop(image, [0, 0, m, n] );

%per problemi di compatibilità tra dimensioni devo fare nuovamente il
%resize
image = imresize(image, size(mask));

mask = im2double(mask);

%combino la maschera con l'immagine
mask = mask .* image;

%trovo il valore medio tra i massimi dell'immagine
m = max(mask);
mm = mean(m);

%in base al valore medio definisco una soglia
if mm < 0.5
    dark = mm - 0.15;
else
    dark = mm - 0.20;
end


%faccio una gamma correction
mask = imadjust(mask, [dark mm-0.1], []);



%binarizzo con una soglia dipendente dal valore medio
%precendente
mask = (mask(:, :) <= mm-0.20);



%ridimensiono l'immagine ad un valore fissato di 40 x 40
mask = imresize(mask, [40 40]);



%a causa di imresize potrebbe non essere più binaria, la
%binarizzo
mask = mask > 0.0;



%la cella potrebbe non esser stata tagliata perfettamente
%potrebbe contenere parti di celle adiacenti
%le elimino mettendole a 0

mask(:, 1:3) = 0;
mask(:, 37:40) = 0;
mask(37:40, :) = 0;
mask(1:3, :) = 0;

%inserisco nello stack che conterrà il risultato la cella
%trovata

respond = mask;



end


function respond = get_cellb(image, mask)

%ottengo la sua boundingbox
box= regionprops(mask, 'Area', 'BoundingBox');
bb = box.BoundingBox;

%ritaglio la maschera con la bb
mask = imcrop(mask, bb );

%ritaglio l'immagine con la bb in modo da avere solo la cella
image= imcrop(image, bb );

%leggo le dimensioni
[n, m] = size(mask);

%croppo di nuovo BW per essere certi che abbia le dimensioni
%corrette
image= imcrop(image, [0, 0, m, n] );

image = imresize(image,  size(mask));


mask = im2double(mask);

%combino l'immagine con la maschera
mask = mask .* image;

%equalizzo l'istogramma
mask = histeq(mask);

%applico una gamma correction
mask = imadjust(mask, [0.1 0.9], []);

%binarizzo l'immagine
mask = (mask <= 0.2);


%ridimensiono l'immagine ad un valore fissato di 40 x 40
mask = imresize(mask, [40 40]);

%binarizzo
mask = mask > 0.0;

%la cella potrebbe non esser stata tagliata perfettamente
%potrebbe contenere parti di celle adiacenti
%le elimino mettendole a 0

mask(:, 1:2) = 0;
mask(:, 38:40) = 0;
mask(38:40, :) = 0;
mask(1:2, :) = 0;


respond = mask;


end