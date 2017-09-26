function plotTLC(light)
global p_NS
global p_EW

if light <= 27
    p_EW.MarkerEdgeColor = 'red';
    p_EW.MarkerFaceColor = 'red';
    p_NS.MarkerEdgeColor = 'green';
    p_NS.MarkerFaceColor = 'green';
elseif light <= 30
    p_EW.MarkerEdgeColor = 'red';
    p_EW.MarkerFaceColor = 'red';
    p_NS.MarkerEdgeColor = 'yellow';
    p_NS.MarkerFaceColor = 'yellow';
elseif light <= 57
    p_EW.MarkerEdgeColor = 'green';
    p_EW.MarkerFaceColor = 'green';
    p_NS.MarkerEdgeColor = 'red';
    p_NS.MarkerFaceColor = 'red';
else
    p_EW.MarkerEdgeColor = 'yellow';
    p_EW.MarkerFaceColor = 'yellow';
    p_NS.MarkerEdgeColor = 'red';
    p_NS.MarkerFaceColor = 'red';
end
hold on
end