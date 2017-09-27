function plotCAV(pos, lane, id)
% function plotCAV(pos, lane, id, light)
global p
global p_color
global p_NS
global p_EW
% p.Visible = 'on';
switch lane
    case 1
        if p_color(id) == 0
            p(id).MarkerEdgeColor = 'yellow';
            p(id).MarkerFaceColor = 'yellow';
            p_color(id) = 1;
        end
        p(id).XData = pos - 415;
        p(id).YData = -7.5;
        
    case 2
        if p_color(id) == 0
            p(id).MarkerEdgeColor = 'red';
            p(id).MarkerFaceColor = 'red';
            p_color(id) = 1;
        end
        p(id).XData = 7.5;
        p(id).YData = pos - 415;
        
        
    case 3
        if p_color(id) == 0
            p(id).MarkerEdgeColor = 'blue';
            p(id).MarkerFaceColor= 'blue';
            p_color(id) = 1;
        end
        p(id).XData = - pos + 415;
        p(id).YData = 7.5;
        
        
    case 4
        if p_color(id) == 0
            p(id).MarkerEdgeColor = 'green';
            p(id).MarkerFaceColor = 'green';
            p_color(id) = 1;
        end
        p(id).XData = -7.5;
        p(id).YData = - pos + 415;
        
        
end

% if light <= 30
%     p_EW.MarkerEdgeColor = 'red';
%     p_EW.MarkerFaceColor = 'red';
%     p_NS.MarkerEdgeColor = 'green';
%     p_NS.MarkerFaceColor = 'green';
% else
%     p_EW.MarkerEdgeColor = 'green';
%     p_EW.MarkerFaceColor = 'green';
%     p_NS.MarkerEdgeColor = 'red';
%     p_NS.MarkerFaceColor = 'red';
% end

end