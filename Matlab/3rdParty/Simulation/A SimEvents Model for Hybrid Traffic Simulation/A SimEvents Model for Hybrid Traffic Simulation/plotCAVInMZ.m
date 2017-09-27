function plotCAVInMZ(pos, lane, dest, id, leftT, rightT)
global p
global p_color

left_rad = leftT;
right_rad = rightT;
switch lane
    case 1
        
        switch mod(dest - lane, 4)
            case 1 % right
                p(id).XData = -15 + right_rad * sin(getTheta(pos - 400, right_rad));
                p(id).YData = -7.5 - right_rad * (1 - cos(getTheta(pos - 400, right_rad)));
            case 2
                p(id).XData = pos - 415;
                p(id).YData = -7.5;
                
            case 3
                p(id).XData =  -15 + left_rad * sin(getTheta(pos - 400, left_rad));
                p(id).YData = -7.5 + left_rad * (1 - cos(getTheta(pos - 400, left_rad)));
        end
        
    case 2
        
        switch mod(dest - lane, 4)
            case 1 % right
                p(id).XData = 7.5 + right_rad * (1 - cos(getTheta(pos - 400, right_rad)));
                p(id).YData = -15 + right_rad * sin(getTheta(pos - 400, right_rad));
            case 2
                p(id).XData = 7.5;
                p(id).YData = pos - 415;
            case 3
                p(id).XData = 7.5 - left_rad * (1 - cos(getTheta(pos - 400, left_rad)));
                p(id).YData = -15 + left_rad * sin(getTheta(pos - 400, left_rad));
        end
        
    case 3
        
        switch mod(dest - lane, 4)
            case 1 % right
                p(id).XData = 15 - right_rad * sin(getTheta(pos - 400, right_rad));
                p(id).YData = 7.5 + right_rad * (1 - cos(getTheta(pos - 400, right_rad)));
            case 2
                p(id).XData = - pos + 415;
                p(id).YData = 7.5;
            case 3
                p(id).XData = 15 - left_rad * sin(getTheta(pos - 400, left_rad));
                p(id).YData = 7.5 - left_rad * (1 - cos(getTheta(pos - 400, left_rad)));
        end
        
    case 4
        
        switch mod(dest - lane, 4)
            case 1 % right
                p(id).XData = -7.5 - right_rad * (1 - cos(getTheta(pos - 400, right_rad)));
                p(id).YData = 15 - right_rad * sin(getTheta(pos - 400, right_rad));
            case 2
                p(id).XData = -7.5;
                p(id).YData = - pos + 415;
            case 3
                p(id).XData = -7.5 + left_rad * (1 - cos(getTheta(pos - 400, left_rad)));
                p(id).YData = 15 - left_rad * sin(getTheta(pos - 400, left_rad));
        end
        
end

end