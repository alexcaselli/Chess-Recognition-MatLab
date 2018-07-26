function fen = read_chessboard(image)

x = find_chessboard(image, 0);
y = straighten_out(x, image);
z = genFen(y);
fen = fen2array(z);
fen = strcat(fen,' - 0 1');
fprintf(strcat(fen, '\n'));
end