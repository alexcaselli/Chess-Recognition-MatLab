function point = rotate_points(bb,  maskp, barAngle)

folder = 'pipe';

%utilizzo le dimensioni della maschera per creare un'immagine nera
s=size(maskp);
marker=zeros(s(1:2));

%prendo il numero di elementi presenti nel vettore mm che corrisponde alle
%coordinate degli angoli della scacchiera
[~,r]=size(bb);

%utilizzo le coordinate di mm (x, y) per creare dei punti bianchi
%nell'immagine nera
for i=1:2:r-1
    
    marker(round(bb(1,i+1)), round(bb(1,i)))=1;
end



%raddrizzo l'immagine con i 4 punti bianchi
marker_rot = imrotate(marker,barAngle,'bilinear','crop');



%a causa dell'interpolazioni ci saranno più punti ed alcuni non avranno più
%valore 1, li soglio
marker_rot = marker_rot > 0.1;



%salvo le coordinate dei punti
[y,x]= find(marker_rot);


point = [];

%dispongo i punti in ordine inverso
movingpoint = [x y];

%utilizzo k-means con k = 4 per raggruppare i punti più vicini
idx = kmeans(movingpoint,4);

%per ogni cluster prendo un solo rappresentante in modo da tornare ad avere
%4 punti
for I=1:4
    finda = 0;
    j=1;
    while finda == 0
        if idx(j) == I
            point = [point; movingpoint(j,:)];
            finda = 1;
        end
        j = j + 1;
    end
end

%ordino i punti in modo da ottenere una figura convessa
k = convhull(point(:,1),point(:,2));
point = point(k,:);

%l'ultimo punto non è necessario, lo elimino
point = point(1:end-1,:);

%ordino le righe
tmp = sortrows(point,[1 2]);

%compio tmp modificando l'ordine
tmp2 = [];
tmp2= [tmp2; tmp(1,:)];
tmp2= [tmp2; tmp(3,:)];
tmp2= [tmp2; tmp(4,:)];
tmp2= [tmp2; tmp(2,:)];
point = tmp2;

%se il primo punto ha coordinate superiori all'ultimo allora l'ordine non è
%corretto, li scambio
if sum(point(1,:)) > sum(point(4,:))
    j = point(1,:);
    point(1,:) = point(4,:);
    point(4,:) = j;
end

%se il secondo punto ha coordinate superiori al terzo allora l'ordine non è
%corretto, li scambio
if sum(point(2,:)) > sum(point(3,:))
    j = point(2,:);
    point(2,:) = point(3,:);
    point(3,:) = j;
end
end