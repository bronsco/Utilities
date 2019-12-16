function contourf3( varargin )
% contourf3( varargin )
%   Plots a 3D coloured contour, as contourf, on a 3D plane. The function
%   requires a minimum of:
% 
%   contourf3(X,Y,Z,C) where X, Y, Z and C are 2D matricies as if X and Y
%   were produced with meshgrid with Z and C corrected as such.
% 
%   All other contourf() inputs can also be accepted, insert them as you
%   would with contourf() after the C.
% 
%   If a colorbar is required, use hold on and use this code in conjunction
%   with a standard contour plot and piggy back that for the colorbar.
% 
%   To change the quality of the surface plot use the standard print()
%   notation '-r600' for example (see example), else print() will use the
%   standard settings.
%   
%   %%%%%%%%%%%%%%%%%%
%   %Example,
%   X = 1:20;
%   Y = 1:10;
%   [X,Y] = meshgrid(X,Y);
%   Z = 2*Y;
%   C = sin(X)+2*tan(Y);
% 
%   contourf3(X,Y,Z,C,'-r600')
%   
%   %%%%%%%%%%%%%%%%%%
%
%   For contour details, type 'help contourf'
%   http://uk.mathworks.com/matlabcentral/fileexchange/61091-contourf3

%% Check to see if data is 2 dimensional
[x_dim,y_dim] = size(varargin{1});
if length(size(varargin{1})) > 2
    error('>2D matrix detected')
elseif x_dim == 1 || y_dim == 1
    error('1D matrix detected')
end

%% Pulling resolution input
for n = 1:length(varargin)
    if ischar(varargin{n}) && (strfind(varargin{n},'-r') == 1)
        resolution = varargin{n};
        varargin(n) = [];
    end
end

%% Finding current axis and if hold is on
if ~isempty(findall(0,'Type','Figure')) && ishold
    cax = gca;
end

%% Plotting the contour in 2D
invisifig = figure('units','normalized','outerposition',[0 0 1 1],'Visible','Off');
invisifig.Color = [1 1 1];
axis_rem = []; %Check if it is a flat plane in space
for n = 1:3
    if length(unique(varargin{n})) == 1
        axis_rem(end+1) = n;
    end
end


if length(axis_rem) > 1
    error('Contour would be on a single line')
end

%If data is on a plane, this decides which plane to plot
if length(axis_rem) == 1
    plot_values = 1:3;
    plot_values = plot_values(plot_values ~= axis_rem);
else
    %This section finds which axes to not plot against x-z or x-y for
    %example if this is a straight line
    if sum(~isnan(uniquetol(gradient(reshape(varargin{1},[],1),reshape(varargin{2},[],1)),0.01))) == 1
        plot_values = [2 3];
    elseif sum(~isnan(uniquetol(gradient(reshape(varargin{1},[],1),reshape(varargin{3},[],1)),0.01))) == 1
        plot_values = [1 2];
    elseif sum(~isnan(uniquetol(gradient(reshape(varargin{2},[],1),reshape(varargin{3},[],1)),0.01))) == 1
        plot_values = [1 3];
    else
        plot_values = [1 3];
    end
end

%plotting the 2D contour
contourf(varargin{plot_values(1)},varargin{plot_values(2)},varargin{4:end})
box off
set(gca,'Unit','normalized','Position',[0 0 1 1])
set(gca,'visible','off')

if exist('resolution','var')
    h = print('-RGBImage',resolution);
else
    h = print('-RGBImage');
end

im = flipud(h);
close(invisifig)

%% Plotting 3D Data
if exist('cax','var')
    surface(cax,varargin{1:3},im,...
        'FaceColor','texturemap',...
        'EdgeColor','none',...
        'CDataMapping','direct')
else
    figure
    surface(varargin{1:3},im,...
        'FaceColor','texturemap',...
        'EdgeColor','none',...
        'CDataMapping','direct')

end

end

