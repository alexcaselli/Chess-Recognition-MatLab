function res = genFen(y)

res = [];
row = [];
j = 1;

%scorro le righe
while j <= 8
    
    %prendo le cellette della riga
    r = getRow(y, j);
    i = 1;
    
    %per ogni colonna
    while i <= 8
        %se il numero di riga è dispari
        if mod(j, 2) ~= 0
            
            %se il numero di colonna è dispari
            if mod(i, 2) ~= 0
                
                %trovo la codifica fen della cella
                tmp = findFen(r(:, :, i), 0);
                
            else % se è pari
                
                tmp = findFen(r(:, :, i), 1);
                
            end
            
        else % se è pari la riga
            
            if mod(i, 2) ~= 0
                
                tmp = findFen(r(:, :, i), 1);
                
            else
                
                tmp = findFen(r(:, :, i), 0);
                
            end
            
            
        end
        
        %incremento il contatore
        i = i + 1;
        
        %aggiungo la codifica della cella alle altre della stessa riga
        row = [row, tmp];
        
    end
    
    %incremento il contatore riga
    j = j + 1;
    
    %aggungo l'intera riga al risultato
    res = [res; row];
    
    %azzero il vettore riga
    row = [];
    
end

%metto il risultato sulla stessa riga (commentata per possibili futuri
%utilizzi)
%res=[res(1,:),res(2,:),res(3,:),res(4,:),res(5,:),res(6,:),res(7,:),res(8,:)];

end