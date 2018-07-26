function x = fen2array(o) %o deve essere una matrice, genfen restituisce un vettore
res = [];
for i=1:8
    sm = 0;
    for j=1:7
        if (str2double(o(i, j)) == 1)
            if(str2double(o(i, j+1)) == 1)
                sm = sm + 1;
            else
                res = [res, num2str(sm+1)];
                sm = 0;
                if j == 7
                    res = [res, o(i, j+1)];
                end
                
            end
        else
            res = [res, o(i, j)];
            if j == 7
                if(str2double(o(i, j+1)) == 1)
                    sm =  -1;
                else
                    res = [res, o(i, j+1)];
                end
                
                
            end
        end
    end
    
    if sm > 0
        res = [res, num2str(sm+1)];
    else
        if sm < 0
            res = [res, num2str(1)];
        end
    end
    if i < 8
        res = [res, '/'];
    end
end

x = "";
for i=1:size(res, 2)
    x = x + res(i);  
end
end
