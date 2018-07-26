function barAngle = find_angle(ime)
[H,T,~] = hough(ime,'RhoResolution',3,'Theta',-90:1:89);



peak = houghpeaks(H);
barAngle = T(peak(2)); %trovo l'angolo con cui raddrizzare
if barAngle > 45
    barAngle = barAngle - 90;
else
    if barAngle < -45
        barAngle = barAngle + 90;
    end
end


end