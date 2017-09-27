function plotBGIMAGEtlc(light)
global p
global p_color
global p_NS
global p_EW
global fuel_legend
global time_legend
eml.extrinsic('imread');
img = imread('figs/storrow.png','png');

% set the range of the axes
% The image will be stretched to this.
min_x = -415;
max_x = 415;
min_y = -415;
max_y = 415;
eml.extrinsic('imagesc');
% Flip the image upside down before showing it
imagesc([min_x max_x], [min_y max_y], flipdim(img, 1));

% set the y-axis back to normal.
set(gca,'ydir','normal');
axis manual
hold on

y = zeros(100, 100) + 1000; %100: number of CAVs

p = plot(y,'o','MarkerSize',3);
p_color = zeros(1, 100); % check if a CAV has determined its color
% axis([0, 50, -10, 20]);

hold on

if light <= 30
    p_EW = plot(-40, 25, '*','MarkerEdgeColor','yellow',...
        'MarkerFaceColor','yellow',...
        'MarkerSize',3);
    p_NS = plot(-25, 40, '*','MarkerEdgeColor','yellow',...
        'MarkerFaceColor','yellow',...
        'MarkerSize',3);
else
    p_EW = plot(-40, 25, '*','MarkerEdgeColor','yellow',...
        'MarkerFaceColor','yellow',...
        'MarkerSize',3);
    p_NS =  plot(-25, 40, '*','MarkerEdgeColor','yellow',...
        'MarkerFaceColor','yellow',...
        'MarkerSize',3);
end

%% Performance
t_val = num2str(0);
txt1 = t_val;
text(30, 200, 'Average Fuel Consumption [l]:');
fuel_legend = text(200, 200, txt1);
hold on
text(30, 180, 'Average Travel Time [s]:');
time_legend = text(200, 180, txt1);
end