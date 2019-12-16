function akZoom2(h_ax)
% allows direct zooming and panning with the mouse in 2D plots.
%
%    Left Mouse Button: pan view
%  Middle Mouse Button: reset view to default view
%   Right Mouse Button: zoom view
%
% SYNTAX:
%   akZoom
%   akZoom(h_ax)
%
% DESCRIPTION:
%   akZoom activates mouse control for all axes-objects in the current figure.
%
%   akZoom(h_ax) activates mouse control for all axes given by the handle
%   array h_ax. The axes can be subplots or even in different figures and are
%   automatically linked. This means that when zooming or panning one axis
%   all others will be affected to.
%
% MODIFIED BY Gijs van Oort, 05/03/2013
%
% EXAMPLES:
%   a) Simple Plot
%     x = linspace(-1, 1, 10000);
%     y = sin(1./x);
%     figure
%     plot(x, y);
%     akZoom();
%   
%   b) Plotyy (linked axes)
%     x = linspace(-1, 1, 10000);
%     y = sin(1./x);
%     y2 = -2*sin(1./(x-0.1));
%     figure
%     ax = plotyy(x,y,x,y2);
%     akZoom(ax);
%
%   c) Plotyy (independent axes)
%     x = linspace(-1, 1, 10000);
%     y = sin(1./x);
%     y2 = -2*sin(1./(x-0.1));
%     figure
%     ax = plotyy(x,y,x,y2);
%     akZoom();
%
%   d) Image
%     figure
%     imagesc(magic(40));
%     akZoom();
%
%   e) Subplots (independent axes)
%     figure
%     for k = 1:4
%       y = rand(1,15);
%       subplot(2, 2, k);
%       plot(y);
%     end
%     akZoom();
%
%   e) Subplots (linked axes)
%     figure
%     ax = NaN(4,1);
%     for k = 1:4
%       y = rand(1,15);
%       ax(k) = subplot(2, 2, k);
%       plot(y);
%     end
%     akZoom(ax);
%
%   f) Different figures (linked)
%     x = linspace(-1, 1, 10000);
%     y = sin(1./x);
%     figure
%     plot(x, y)
%     ax(1) = gca;
%     figure
%     plot(x, y)
%     ax(2) = gca;
%     akZoom(ax);
%
%
% KNOWN BUGS
% a) Strange double tick marks appear while you draw the ROI-rectangle in figures with an image in it.
%    This happens in old Matlab-Versions and is a bug of the Matlab OpenGl-Renderer
%    You can avoid this by switching to software rendering:   opengl software
%
%
% Author: Alexander Kessel
% Affiliation: Max-Planck-Institut für Quantenoptik, Garching, Munich
% Contact : alexander.kessel <at> mpq.mpg.de
% Revision: April 2013
%
% Credits go to Rody P.S. Oldenhuis for his mouse_figure function which 
% served as the template for akZoom and to Kang Zhao for the gpos function.

% Specify axes and figures
if nargin == 0
  h_fig = get(0,'CurrentFigure');
  if isempty(h_fig)
    error('akZoom:no_figure_open', 'There is no open figure.');
  end
  h_ax = findobj(gcf,'type','axes'); % use all axes in figure
  linkAxes = false; % by default do not link axes 
else
  h_fig = NaN(size(h_ax));
  for j=1:numel(h_ax)
    h_fig(j) = get(h_ax(j), 'Parent'); % get figures of all axes
  end
  linkAxes = true; % link specified axes
end
linkaxes(h_ax, 'off'); % turn off matlab-linking if it is on. akZoom is linking axes its own

% check if plot is 2D plot
if ~any(is2D(h_ax)) % is2D might disappear in a future release...
  error('akZoom:plot3D_not_supported', 'akZoom() only works for 2-D plots.');
end

% Initialize variables for use across all nested functions
cx = []; % clicked x-coordinate
cy = []; % clicked y-coordinate
cx_pixels = [];
cy_pixels = [];
mode = ''; % navigation mode, e.g. 'pan'
ROI = []; % This will later hold the patch object that marks the zoom area.

% save original limits
original_xlim = NaN(numel(h_ax),2);
original_ylim = NaN(size(original_xlim));
for j=1:numel(h_ax)
  original_xlim(j,:) = get(h_ax(j), 'xlim');
  original_ylim(j,:) = get(h_ax(j), 'ylim');
end

% set callbacks for all figures
for j=1:numel(h_fig)
  set(h_fig(j), ...
    ...%'WindowScrollWheelFcn' , @scroll_zoom,...
    ...%'WindowButtonDownFcn'  , @MouseDown,...
    'WindowButtonUpFcn'    , @MouseUp,...
    'WindowButtonMotionFcn', @MouseMotion);
end

for j=1:numel(h_ax)
  set(h_ax(j), ...
    ...%'WindowScrollWheelFcn' , @scroll_zoom,...
    'ButtonDownFcn'  , @MouseDown);
    %'WindowButtonUpFcn'    , @MouseUp,...
    %'WindowButtonMotionFcn', @MouseMotion);
end


% zoom in to cursor point with the mouse wheel
%   function scroll_zoom(varargin)
%     currAx = h_ax( get(gcf, 'currentaxes') == h_ax );
%     if isempty(currAx), return, end %return if the current axis is not one of the axes specified at the beginning
%     [x,y]=gpos(gcf, currAx);
%     [x_rel, y_rel] = abs2relCoords(currAx, x, y);
%     wheel_zoomFactor = 1+varargin{2}.VerticalScrollCount/5;
%     
%     for i = affectedAxes()
%       [x, y] = rel2absCoords(h_ax(i), x_rel, y_rel);
%       XLim = get(h_ax(i), 'xlim');
%       new_XLim = (XLim-x)*wheel_zoomFactor + x;
%       set(h_ax(i),'xlim',new_XLim);
%       
%       YLim = get(h_ax(i), 'ylim');
%       new_YLim = (YLim-y)*wheel_zoomFactor + y;
%       set(h_ax(i),'ylim',new_YLim);
%     end
%   end

  function MouseDown(varargin)
    currAx = h_ax( get(gcf, 'currentaxes') == h_ax);
    if isempty(currAx), return, end %return if the current axis is not one of the axes specified at the beginning
    % save clicked coordinates to cx and cy
    [cx, cy] = GetClickedCoords(currAx);
    [cx_pixels,cy_pixels] = GetClickedCoordsPixels(currAx);
    switch lower(get(gcf, 'selectiontype'))
      case 'normal' %left button
        mode = 'pan';
      case 'extend' %middle button
        for i = affectedAxes()
          set(h_ax(i), 'Xlim', original_xlim(i,:), 'Ylim', original_ylim(i,:));
        end
      case 'alt' % right press
          mode = 'zoommotion';
      case 'not_functional' % I don't use this
        mode = 'selectROI';
        % create ROI rectangle object
        ROI = patch();%'Parent', currAx);
        % set position and appearance of ROI rectangle
        set(ROI, ...
          'XData', [cx cx cx cx], ...
          'YData', [cy cy cy cy], ...
          'EdgeColor', 'k', ...
          'FaceColor', 'r', ...
          'FaceAlpha', 0.1, ...
          'LineWidth', 0.5, ...
          'LineStyle', '-');
    end
  end

  function MouseUp(varargin)
    currAx = h_ax( get(gcf, 'currentaxes') == h_ax);
    if isempty(currAx), return, end %return if the current axis is not one of the axes specified at the beginning
    if strcmp(mode, 'selectROI')
      % get corner points of ROI in relative coordinates
      x = get(ROI, 'XData');
      y = get(ROI, 'YData');
      [x_rel1, y_rel1] = abs2relCoords(currAx, x(1), y(1));
      [x_rel2, y_rel2] = abs2relCoords(currAx, x(2), y(3));
      for i = affectedAxes()
        % calc absolute coordinates of ROI corners
        [x1, y1] = rel2absCoords(h_ax(i), x_rel1, y_rel1);
        [x2, y2] = rel2absCoords(h_ax(i), x_rel2, y_rel2);
        new_xlim = sort([x1, x2]);
        new_ylim = sort([y1, y2]);
        if diff(new_xlim) && diff(new_ylim) % check valid limits
          % set limits
          set(h_ax(i), 'xlim', new_xlim, 'ylim', new_ylim)
        end
      end
      delete(ROI);
    end
    mode = '';
  end

  function MouseMotion(varargin)
        if isempty(cx), return, end % return if there is no clicked point set
        currAx = h_ax( get(gcf, 'currentaxes') == h_ax); 
        if isempty(currAx), return, end %return if the current axis is not one of the axes specified at the beginning
        [x,y] = GetClickedCoords(currAx);
        if strcmp(mode, 'pan')
          xlim = get(currAx, 'xlim');
          ylim = get(currAx, 'ylim');
          % find change in position
          delta_x = x - cx;
          delta_y = y - cy;
          % calculate relative change in position
          delta_x_rel = delta_x/diff(xlim);
          delta_y_rel = delta_y/diff(ylim);
          for i = affectedAxes()
            xlim = get(h_ax(i), 'xlim');
            ylim = get(h_ax(i), 'ylim');
            % adjust limits
            new_xlim = xlim - delta_x_rel*diff(xlim);
            new_ylim = ylim - delta_y_rel*diff(ylim);
            % set new limits
            set(h_ax(i), 'Xlim', new_xlim, 'Ylim', new_ylim);
          end
          % save new position
          [cx,cy] = GetClickedCoords(currAx);
        elseif strcmp(mode,'zoommotion')
          [x_pixels,y_pixels] = GetClickedCoordsPixels(currAx);
          % xlim = get(currAx, 'xlim');
          % ylim = get(currAx, 'ylim');
          % find change in position in pixels
          delta_x_pixels = x_pixels - cx_pixels;
          delta_y_pixels = y_pixels - cy_pixels;

          p = 1.005; % Zoom per pixel
           zoomFactorX = p^delta_x_pixels;
           zoomFactorY = p^delta_y_pixels;

          for i = affectedAxes()
            xlim = get(h_ax(i), 'xlim');
            ylim = get(h_ax(i), 'ylim');

            % adjust limits for x axes
            new_width = diff(xlim) / zoomFactorX;
            if new_width>1e6,  new_width = 1e6; end;
            if new_width<1e-6, new_width = 1e-6; end;
            new_xlim = mean(xlim)+ [-0.5,0.5] * new_width;
            
            % adjust limits for y axes
            new_height = diff(ylim) / zoomFactorY;
            if new_height>1e6,  new_height = 1e6; end;
            if new_height<1e-6, new_height = 1e-6; end;
            new_ylim = mean(ylim)+ [-0.5,0.5] * new_height;
            % set new limits
            set(h_ax(i), 'Xlim', new_xlim, 'Ylim', new_ylim);
          end
          % save new position
          [cx,cy] = GetClickedCoords(currAx);
          cx_pixels = x_pixels;
          cy_pixels = y_pixels;
            
        elseif strcmp(mode, 'selectROI')
          % resize ROI rectangle
          set(ROI, ...
            'XData', [cx x x cx], ...
            'YData', [cy cy y y]);
        else % no mode
          return;
        end
  end

function i_ax = affectedAxes()
currAx = h_ax( get(gcf, 'currentaxes') == h_ax);
if isempty(currAx) 
  i_ax = [];
else
  if linkAxes
    i_ax = 1:numel(h_ax); % use all axes 
  else
    i_ax = get(gcf, 'currentaxes') == h_ax; % use only current axis
  end
end
end

end

function [x, y, z] = GetClickedCoords(h_ax)
crd = get(h_ax, 'CurrentPoint');
x = crd(2,1);
y = crd(2,2);
z = crd(2,3);
end

function [x_pixels, y_pixels] = GetClickedCoordsPixels(handle)
% Returns the position of the cursor in pixels

while true % Get figure in which this axis is
    parent = get(handle,'parent');
    if parent==0, break; end; % then h_ax points to the figure
    handle = parent;
end;

crd = get(handle, 'CurrentPoint');
x_pixels = crd(1);
y_pixels = crd(2);
end

function [x_rel, y_rel] = abs2relCoords(h_ax, x, y)
XLim = get(h_ax, 'xlim');
x_rel = (x-XLim(1))/(XLim(2)-XLim(1));
YLim = get(h_ax, 'ylim');
y_rel = (y-YLim(1))/(YLim(2)-YLim(1));
end

function [x, y] = rel2absCoords(h_ax, x_rel, y_rel)
XLim = get(h_ax, 'xlim');
x = x_rel*diff(XLim)+XLim(1);
YLim = get(h_ax, 'ylim');
y = y_rel*diff(YLim)+YLim(1);
end



function [x,y]=gpos(h_figure, h_axes)
% Written by Kang Zhao,DLUT,Dalian,CHINA. 2003-11-19
% E-mail:kangzhao@student.dlut.edu.cn

units_figure = get(h_figure,'units');
units_axes   = get(h_axes,'units');

if_units_consistent = 1;

if ~strcmp(units_figure,units_axes)
  if_units_consistent=0;
  set(h_axes,'units',units_figure); % To be sure that units of figure and axes are consistent
end

% Position of origin in figure [left bottom]
pos_axes_unitfig    = get(h_axes,'position');
width_axes_unitfig  = pos_axes_unitfig(3);
height_axes_unitfig = pos_axes_unitfig(4);

xDir_axes=get(h_axes,'XDir');
yDir_axes=get(h_axes,'YDir');

% Cursor position in figure
pos_cursor_unitfig = get( h_figure, 'currentpoint'); % [left bottom]

if strcmp(xDir_axes,'normal')
  left_origin_unitfig = pos_axes_unitfig(1);
  x_cursor2origin_unitfig = pos_cursor_unitfig(1) - left_origin_unitfig;
else
  left_origin_unitfig = pos_axes_unitfig(1) + width_axes_unitfig;
  x_cursor2origin_unitfig = -( pos_cursor_unitfig(1) - left_origin_unitfig );
end

if strcmp(yDir_axes,'normal')
  bottom_origin_unitfig     = pos_axes_unitfig(2);
  y_cursor2origin_unitfig = pos_cursor_unitfig(2) - bottom_origin_unitfig;
else
  bottom_origin_unitfig = pos_axes_unitfig(2) + height_axes_unitfig;
  y_cursor2origin_unitfig = -( pos_cursor_unitfig(2) - bottom_origin_unitfig );
end

xlim_axes=get(h_axes,'XLim');
width_axes_unitaxes=xlim_axes(2)-xlim_axes(1);

ylim_axes=get(h_axes,'YLim');
height_axes_unitaxes=ylim_axes(2)-ylim_axes(1);

x = xlim_axes(1) + x_cursor2origin_unitfig / width_axes_unitfig * width_axes_unitaxes;
y = ylim_axes(1) + y_cursor2origin_unitfig / height_axes_unitfig * height_axes_unitaxes;

% Recover units of axes,if original units of figure and axes are not consistent.
if ~if_units_consistent
  set(h_axes,'units',units_axes);
end
end