function res = findFen(im, col)

folder = 'templates';

%leggo i template dei pezzi
BLANKB = 'BLANKB.png';
CBB = 'Nb.png';
CNB = 'CNB.png';
FNB = 'FNB.png';
KBB = 'KBB.png';  
PBB = 'Pb.png';
FBB = 'Bb.png';
PNB = 'PNB.png';
QBB = 'Qb.png';
QNB = 'QNB.png';
TBB = 'TBB.png';
TNB = 'TNB.png';

TNN = 'rn.png';
TBN = 'TBN.png';
QNN = 'QNN.png';
QBN = 'QBN.png';
PNN = 'PNN.png';
PBN = 'Pb.png';
KBN = 'KBN.png';
FNN = 'FNN.png';
FBN = 'Bn.png';
CNN = 'nn.png';
CBN = 'CBN.png';


rn =  im2double(imread(strcat(folder, '/', TNN)));
Rn =  im2double(imread(strcat(folder, '/', TBN)));
qn =  im2double(imread(strcat(folder, '/', QNN)));
Qn =  im2double(imread(strcat(folder, '/', QBN)));
pn =  im2double(imread(strcat(folder, '/', PNN)));
Pn =  im2double(imread(strcat(folder, '/', PBN)));
Kn =  im2double(imread(strcat(folder, '/', KBN)));
bn =  im2double(imread(strcat(folder, '/', FNN)));
Bn =  im2double(imread(strcat(folder, '/', FBN)));
nn =  im2double(imread(strcat(folder, '/', CNN)));
Nn =  im2double(imread(strcat(folder, '/', CBN)));

pieces = ['K', 'Q', 'q', 'R', 'r', 'B', 'b', 'N', 'n', 'P', 'p', '1'];
blacks=cat(3, Kn(:, :, 1), Qn(:, :, 1), qn(:, :, 1), Rn(:, :, 1), rn(:, :, 1), Bn(:, :, 1), bn(:, :, 1), Nn(:, :, 1), nn(:, :, 1), Pn(:, :, 1), pn(:, :, 1));

BLANKB =  im2double(imread(strcat(folder, '/', BLANKB)));
Nb =  im2double(imread(strcat(folder, '/', CBB)));
nb =  im2double(imread(strcat(folder, '/', CNB)));
Bb =  im2double(imread(strcat(folder, '/', FBB)));
bb =  im2double(imread(strcat(folder, '/', FNB)));
Kb =  im2double(imread(strcat(folder, '/', KBB)));
Pb =  im2double(imread(strcat(folder, '/', PBB)));
pb =  im2double(imread(strcat(folder, '/', PNB)));
Qb =  im2double(imread(strcat(folder, '/', QBB)));
qb =  im2double(imread(strcat(folder, '/', QNB)));
Rb =  im2double(imread(strcat(folder, '/', TBB)));
rb =  im2double(imread(strcat(folder, '/', TNB)));


whites=cat(3, Kb(:, :, 1), Qb(:, :, 1), qb(:, :, 1), Rb(:, :, 1), rb(:, :, 1), Bb(:, :, 1), bb(:, :, 1), Nb(:, :, 1), nb(:, :, 1), Pb(:, :, 1), pb(:, :, 1),BLANKB);



%il valore base da superare per poter essere considerata una cella non
%vuota
maxi = -0.3;

%se non trovo una corrispondenza valida la considero come una cella bianca
r = 12; %se 0 errore

%se il colore della cella è bianco
i = 1;
if col == 0
    
    %valuto la corrispondenza con ogni template possibile
    while i <= 12
        
        %letto il tamplate
        mask = whites(:, :, i);
        
        %valuto la corrispondenza
        x = caseval(im, mask, 1);
        
        %aggiorno la corrispondenza massima
        if x > maxi
            maxi = x;
            r = i;
        end
        
        
        i = i + 1;
        
    end
    
else  %la cella è nera

    %faccio il labelling delle componenti connesse
    labels = bwlabel(im);
    nlabel = max(max(labels(:, :)));
    tn = zeros(size(im));
    tn1 = zeros(size(im));
    
    %filtro le cc in modo da avere in tn solo quelle con area > 1
    %mentre in tn1 solo quelle con area > 3
    for lil=1:nlabel
        x = sum(sum(labels(:, :) == lil));
        if(x > 1)
            tn = tn + (labels == lil);
            if(x > 3)
                tn1 = tn1 + (labels == lil);
            end
        end
    end
    
    %aggiorno l'immagine filtrata
    im = tn1;
    

    
    %la ruoto di 45°
    tn = imrotate(tn, -45);
    

    
    %la riporto a valori tra 0 e 1
    tn = im2double(tn);
    
    %creo un'immagine vuota con le dimensioni di tn
    pn = zeros(size(tn));
    
    %con la rotazione potrebbero essersi create nuove piccole zone spurie
    %effettuo nuovamente il filtraggio con le cc
    labels = bwlabel(tn);
    nlabel = max(max(labels(:, :)));
    for lil=1:nlabel
        x = sum(sum(labels(:, :) == lil));
        if(x > 1)
            pn = pn + (labels == lil);
            
        end
    end
    
    
    %la riporto a valori tra 0 e 1
    pn = im2double(pn);
    
    
    
    % ritaglio l'immagine con l'uso della boundingbox e la rendo binaria
    box = regionprops(pn, 'Centroid', 'BoundingBox');
    pn = imcrop(pn, box.BoundingBox );
    pn = pn >0;
    

    
    %sommo i valori delle righe dell'immagine
    v = sum(pn, 2);
    
    %salvo il numero di valori di v
    [rows ,  ~] = size(v);
    
    %porto i valori di v = 0 a 1
    zeri = v == 0;
    
    %sommando trovo il numero di righe dell'immagine che non conmtengono
    %valori
    zeri = sum(zeri); 
    
    %se il numero di zeri è maggiore o uguale a numero totali di possibili
    %valori * 0.155 allora la cella è vuota
    if(zeri >= rows * 0.155)  
        
        r = 12;
        
    else %altimenti procedo nel template matching come per le celle bianche ma senza il template della cella vuota
        
        while i <= 11
            
   
            mask = blacks(:, :, i);
            x = caseval(im, mask, 0);
            if x > maxi
                maxi = x;
                r = i;
            end
            
            
            i = i + 1;
        end
    end
end

%ritorno il carattere che indica il pezzo che ha ottenuto il maggior valore
%di affinità
res = pieces(r);

end
