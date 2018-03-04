function [xc,yc,r]=fitcircle(x,y)
% [xcenter,ycenter,circleRadius]=fitcircle(x,y)
% MMK mcivilkabiri@yahoo.com
% 
%
    abc = [x y ones(length(x),1)] \ [-(x.^2 + y.^2)];
    a = abc(1);
    b = abc(2);
    c = abc(3);
xc = -a/2;
yc = -b/2;
r = sqrt((xc^2 + yc^2) - c);

end