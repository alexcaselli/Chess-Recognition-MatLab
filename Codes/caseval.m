function res = caseval(im, mask,col)

folder = 'pipe';

% elimino alcune imperfezioni generate in fasi precedenti
im(:,1:2) = 0;
im(:,38:40) = 0;
im(38:40,:) = 0;
im(1:2,:) = 0;
mask(:,1:2) = 0;
mask(:,38:40) = 0;
mask(38:40,:) = 0;
mask(1:2,:) = 0;

%il valore di default ritornato è -1
res = -1;

%calcolo l'area degli oggetti rappresentati nell'immagine della cella e
%della maschera
valim = sum(sum(im));
valmask = sum(sum(mask));


%salvo le dimensioni dell'immagine
[righe,colonne] = size(im);



%se la cella è bianca
if col == 1
    
    %se sto testando un'immagine praticamente vuota e la maschera della
    %cella vuota allora al 90% è la cella vuota
    if(valim <= (5*(righe*colonne))/100) && (valmask <= (5*(righe*colonne))/100)
        res = 0.9;
        
    else
        
        %se l'immagine non è vuota e la maschera non è quella della cella
        %vuota
        if(valim >= (5*(righe*colonne))/100) && (valmask >= (7*(righe*colonne))/100)  %Le dimensioni non coincindono dopo imcrop, forse conviene fare 2 metodi in base al colore anche qui
            
            
            %porto l'immagine a valori tra 0 e 1
            im = im2double(im);

            
            %boundingbox immagine
            boxim = regionprops(im,'Centroid', 'BoundingBox');
            
            %bb maschera
            boxmask = regionprops(mask,'Centroid', 'BoundingBox');
            
            boxim=boxim.BoundingBox;
            boxmask=boxmask.BoundingBox;
            
            
            %le due bounding box potrebbero non essere perfettamente
            %quadrate, correggo il problema accorciando la dimensione
            %maggiore
            boxmask = correct_bb(boxmask);
    
            boxim = correct_bb(boxim);
            
            
            
            
            %ritaglio la maschera con la bb
            mask = imcrop(mask,boxmask );

            
            %ritaglio l'immagine con la bb
            im = imcrop(im,boxim);

            
            %leggo le dimensioni della maschera
            [l,m] = size(mask);
            
            %può capitare che imcrop non restituisca un'immagine con le
            %dimensioni attese, faccio il resize per sicurezza
            im = imresize(im, [l m]);
            
            
            %la binarizzo per correggere l'interpolazione
            im = im >0;
            
            %calcolo nuovamente valmask
            valmask = sum(sum(mask));
            
            %se il nuovo valore dell'immagine è molto superiore a quello
            %originale portrei aver creato nuove regioni non desiderate,
            %erodo
            if(sum(sum(im)) >= valim*1.3)
                ss = strel('square',2);
                im = imerode(im,ss);
            end
            
            %combino immagine e maschera
            r = im .* mask;

            
            %            figure;
            %subplot(1,3,1),imshow(im);
            %subplot(1,3,2),imshow(mask);
            %subplot(1,3,3),imshow(r);
            
            %calcolo il valore dell'immagine cosi creata
            valr = sum(sum(r));
            
            %se il valore della maschera è molto minore di quello
            %dell'immagine 
            if valmask * 3 < valim
                
                res = (valr/valmask) * (valmask/valim);
                
            else
                %in base alle differenze di valore tra valmask e valim
                %applico calcoli differenti
                if valmask > 100+valim
                    
                    if valmask > 300 + valim
                        
                        res = (1.1*(valr/valmask)) - ((1-(valr/valim))*0.6)-0.30;
                        
                    else
                        
                        res = (1.1*(valr/valmask)) - ((1-(valr/valim))*0.6)-0.15; 
                        
                    end
                                    
                 
                else
                    
                    res = (1.2*(valr/valmask)) - ((1-(valr/valim))*0.7);
                end
                
            end
        end
        
    end
    
    
else % se la cella è nera
    
    %procedo come per la cella bianca
    im = im2double(im);

    
    boxim = regionprops(im,'Centroid', 'BoundingBox');
    boxmask = regionprops(mask,'Centroid', 'BoundingBox');
    boxim=boxim.BoundingBox;
    boxmask=boxmask.BoundingBox;
    
    boxmask = correct_bb(boxmask);
    boxim = correct_bb(boxim);
    
    mask = imcrop(mask,boxmask );

    im = imcrop(im,boxim );

    [l,m] = size(mask);
    im = imresize(im, [l m]);
    im = im >0;
    
    
    valmask = sum(sum(mask));
    
    if(sum(sum(im)) >= valim*1.2)
        
        ss = strel('square',2);
        im = imerode(im,ss);
        
    end
    
    r = im .* mask;

    
    %            figure;
    %subplot(1,3,1),imshow(im);
    %subplot(1,3,2),imshow(mask);
    %subplot(1,3,3),imshow(r);
    
    
    valr = sum(sum(r));
    
    if valmask * 3 < valim
        
        res = (valr/valmask) * (valmask/valim);
        
    else
        
        res = (1.1*(valr/valmask)) - ((1-(valr/valim))*0.4);
        
    end
    
    
end
close all;

end



function boxbb = correct_bb(boxbb)
%le due bounding box potrebbero non essere perfettamente
%quadrate, correggo il problema accorciando la dimensione
%maggiore

if boxbb(3) > boxbb(4)
    split = (boxbb(3)-boxbb(4))/2;
    boxbb(4) = boxbb(3);
    boxbb(2) = boxbb(2)-split;
else
    if boxbb(3) < boxbb(4)
        split = (boxbb(4)-boxbb(3))/2;
        boxbb(3) = boxbb(4);
        boxbb(1) = boxbb(1)-split;
    end
end
end