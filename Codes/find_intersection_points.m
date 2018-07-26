function XY=find_intersection_points(rhos,thetas,rows,cols)
% Dobbiamo risolvere un sistema lineare in due equazioni:
%   rho1=x*cos(theta1)+y*sin(theta1)
%   rho2=x*cos(theta2)+y*sin(theta2)
% Testiamo tutte le possibili coppie di rette
% Solo i punti che sono dentro l'immagine sono utili
w = warning ('off','all');

n = numel(rhos);
XY=[];
for i = 1 : n
    for j = i+1 : n
        A=[cos(thetas(i)) sin(thetas(i)); cos(thetas(j)) sin(thetas(j))];
        B=[rhos(i);rhos(j)];
        C = mldivide(A,B);
        x=C(1);y=C(2);
        if (x<0) || (y<0) || x>cols || y>rows
            continue;
        end
        XY=[XY;x y];
    end
end
k = convhull(XY(:,1),XY(:,2));
XY = XY(k,:);



XY = XY(1:end-1,:); % L'ultimo punto coincide con il primo. Lo togliamo.
end