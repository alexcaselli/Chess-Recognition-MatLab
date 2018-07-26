function r = find_chessboard(image, funz)

%porto l'immagini a valori tra 0 e 1
im = im2double(image);

%calcolo il fattore di scaling e scalo l'immagine
im = find_scale(im);

%trovo la maschera che contiene il foglio
mask = find_paper(im);

%converto in scala di grigi
img = rgb2gray(im);


%gamma correction per eventuali ombre
J = imadjust(img, stretchlim(img), []);

%contrasto l'immagine
imc = imadjust(J, [0.30 0.8], []);


%binarizzo con algoritmo sauvola
BW = sauvola(imc, [65 65]);

%combino ma maschera con l'immagine binaria
paperBW = mask .* BW;

%creo un'immagine con le dimensioni di paperBW
mask3 = zeros(size(paperBW));

%dimensione raggio primo elemento strutturante
dim1 = 0;

%dimensione raggio secondo elemento strutturante
dim2 = 0;

stop = 0;

%ciclo finchè mask3 non ha sufficenti elementi per essere una maschera
%oppure finchè dim2 è <= 3
while ((sum(sum(mask3)) < 10)  && (stop ~= 1))
    
    %elementi strutturanti per pulizia della maschera
    se = strel('disk', dim1);
    st = strel('disk', dim2);
    
    %faccio una open per eliminare eventuali piccoli pixel non necessari
    papero = imopen(paperBW, se);
    
    
    %faccio una close per eliminare eventuali piccoli buchi
    paperc = imclose(papero, st);
    
    
    %applico un filtro di smoothing 2x2 per eliminare eventuali bordi
    %troppo seghettati
    paperc = imgaussfilt(paperc, 2);
    
    
    %trovo gli edge dell'immagine con canny
    ime = edge(paperc, 'canny', [], 1);
    
    
    %riempio gli edge chiusi sperando di poter così ottenere una maschera
    %della scacchiera
    mask2 = imfill(ime, 'holes');
    
    
    %elementi strutturanti a diverse angolazioni per rifinire la maschera
    so = strel('line', 70, 0);
    sv = strel('line', 70, 90);
    
    %elimino probabili falsi positivi eseguendo 2 open
    mask3 = imopen(mask2, so);
    mask4 = imopen(mask2, sv);
    
    
    %combino le due maschere in modo da ottenere una maschera più precisa
    %possibile
    mask3 = mask3 .* mask4;
    
    
    %incremento le dimensioni dei due elementi strutturanti
    dim2 = dim2 +1;
    dim1 = dim2 +1;
    
    %dim2 è utilizzata anche come contatore per i cicli, al terzo ciclio la
    %variabile stop viene settata a 1
    if (dim2 >= 3)
        stop = 1;
    end
    
end

%r è la maschera appena trovata, siccome può contenere più componenti
%connesse scegliamo solo quella di area massima che rappresenta la nostra
%scacchiera/foglio della scacchiera
r = mask3;

labels = bwlabel(r);
nlabel = max(max(labels(:, :)));
maxi = sum(sum(labels(:, :) == 1));
label=1;
for i=2:nlabel
    x = sum(sum(labels(:, :) == i));
    if(x > maxi)
        maxi = x;
        label = i;
    end
end

%se il parametro funz = 0 il valore di ritorno sarà la maschera della cc
%con area massima

%se il paramentro funz = 1 il valore di ritorno sarà la combinazione della
%maschera con l'immagine originale scalata precedentemente

%sarà 'errore' altrimenti

if funz == 0
    r = (labels == label);
    
else
    if funz == 1
        mask3 = (labels == label);
        r = mask3 .* im;
    else
        r = 'error';
    end
end
end

