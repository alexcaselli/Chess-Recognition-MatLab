function result = straighten_out_rectangle(image, photo)

%creo un elemento strutturante quadrato
se = strel('square', 20);

%richiamo find_chessboard perchè non ho ancora trovato la scacchiera,
x = find_chessboard(photo, 0);

%prendo le misure della BB che continere l'intero foglio
box = regionprops(x, 'Area', 'BoundingBox');

%richiamo findchessboard con parametro 1 così che restituisca la combinazione della maschera con l'immagine
y = rgb2gray(find_chessboard(photo, 1));


%croppo l'immagine in  modo da avere solo il foglio
k = imcrop(y, box.BoundingBox);



%ri-cerco gli edge, sta volta il bordo del foglio sarà tagliato dall'immagine e non sarà chiuso
e =  edge(k, 'canny', [], 3);



%riempio gli edge chiusi sperando di poter così ottenere una maschera della scacchiera
f = imfill(e, 'holes');


%prendo le dimensioni dell'immagine degli edge
[righe, colonne] = size(e);

%se la mashera creata con imfill non ha dimensioni tali da far pensare che
%possa essere effettivamente la maschera della scacchiera, provo a
%richiamare canny con un parametro differente
if (sum(sum(f)) < righe*colonne * 0.3) % se la maschera trovata è troppo piccola per essere la scacchiera, magari ho un edge non continuo, allora cambio il parametro di canny
    
    %ri-cerco gli edge
    e =  edge(k, 'canny', [], 2);
    
    %riempio gli edge chiusi sperando di poter così ottenere una maschera della scacchiera
    f = imfill(e, 'holes');
     
end

%se il problema persiste forse non è il foglio bensì la sola scacchiera
if (sum(sum(f)) < righe*colonne * 0.3)
    
    
    result = straighten_out_square(image,  photo);
    
else
    
    %pulisco la maschera
    mask = imopen(f, se);
    
    
    
    %siccome può contenere più componenti
    %connesse scegliamo solo quella di area massima che rappresenta la nostra
    %scacchiera/foglio della scacchiera
    
    labels = bwlabel(mask);
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
    mask = (labels == label);
    
    
    
    %ricacolo le dimensioni della nuova maschera
    stats = regionprops('table', mask, 'Centroid', ...
        'MajorAxisLength', 'MinorAxisLength');
    x = stats.MajorAxisLength;
    y = stats.MinorAxisLength;
    
    %se la maschera trovata è quadrata (rispetta i vincoli dell'if)
    if ((x/y >= 0.65) && (x/y <= 1.35))
        
        %numero di linee trovate
        r = 0;
        
        %rotazione aggiuntiva
        add = 0;
        
        
        %finchè non trovo 4 linee, la ruoto di più
        while(r<4)
            
            %ruoto la maschera
            image = imrotate(mask, 10+add);
            
            %trovo gli edge
            ime = edge(image, 'canny', [], 1);
            
            
            %cerco le 4 linee con hough
            [H, T, R] = hough(ime, 'RhoResolution', 3, 'Theta', -90:1:89);
            
            
            coords = houghpeaks(H, 4);
            
            %se non ho trovato 4 linee
            if numel(coords(:, 1)) >= 4
                
                rhos   = R(coords(:, 1));
                thetas = T(coords(:, 2));
                thetas = thetas*pi/180;
                
                
                [rows, cols] = size(ime);
                
                %trovo i punti di interseione
                XY=find_intersection_points(rhos, thetas, rows, cols);
                
                %in r cè il numero di linee
                [r , ~] = size(XY);
                
                if(r~=4)%se le linee non sono 4, ruota di più
                    
                    add = add +10;
                    
                end
                
            else
                
                add = add +10;
                
            end
            
        end %esco perchè ho 4 linee
        
        
        %uso i punti di hough per creare una maschera corretta
        bb = [XY(1, 1) XY(1, 2) XY(2, 1) XY(2, 2) XY(3, 1) XY(3, 2) XY(4, 1) XY(4, 2)];
        maskp = insertShape(im2double(image), 'FilledPolygon', bb, ...
            'Color',  'white', 'Opacity', 1);
        
        
        
        
        %creo un elemento strutturante per correggere la maschera
        strut = strel('square', 3);
        
        %la erodo per eliminare parti indesiderate
        maskp = imerode(maskp, strut);
        
        
        %ruoto la maschera
        barAngle = find_angle(ime);
        
        
        
        %leggo l'immagine originale e la converto in un'immagine a livelli di
        %grigio con valori tra 0 e 1
        gy = rgb2gray(im2double(photo));
        %scalo l'immagine
        gy = find_scale(gy);
        
        %croppo l'immagine in modo da avere solo la scacchiera
        gy = imcrop(find_scale(gy), box.BoundingBox);
        
        %ruoto l'immagine di 15° come fatto inizialmente
        gy = imrotate(gy, 10 + add);
        
        
        
        
        
        %combino gy con il secondo canale della maschera contenente la shape
        %inserita
        gy = gy .* maskp(:, :, 2);
        
        
        
        %raddrizzo gy con l'angolo trovato precedentemente
        res = imrotate(gy, barAngle, 'bilinear', 'crop');
        
        
        
        %ruoto anche la maschera in modo da renderla nuovamente componibile
        image = imrotate(maskp, barAngle, 'bilinear', 'crop');
        
        
        
        
        
        %ruoto i 4 punti guida ed ottengo le loro coordinate dopo la
        %rotazione
        point = rotate_points(bb, maskp, barAngle);
        
        
        
        %ottengo i punti di destinazione per la correzione geometrica
        fixedPoints = get_fixedpoints(image);
        
        %stabilisce la correzzione prospettica usando come punti di partenza quelli
        %trovati precedentemente
        tform = fitgeotrans(point, fixedPoints, 'projective');
        
        
        %applica la correzione prospettica defunita da tform
        A = imwarp(res, tform);
        
        
        
        
        
        
    end
    result = A;
end
end