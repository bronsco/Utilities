% plot_array(X,IxRow,TITLE,Y_LIMITS,IxLegend)
% % plot_array function plots in a single figure all rows of the variable X
% % inputs:
% %  X = matrix [n x m] % n: channels and m: samples
% %           - if the first row is  monotonical increasing it will be used as
% %              x axes (e.g. time)
% %      if X is a cell array of matrix with the same size each row of each
% %      cell will be held on the same line
% %  IxRow = cell array of n  cells string used for specifying ylabels
% %  TITLE = is a string used as the title of the first subplot
% %  Y_LIMITS = two elements vectors indicating the ylim for each row
% % outputs:
% %  F_handle = figure's handle
% % ------------
% % % examples:
% % % ------------
% % % plot a matrix of 10 channels and 500 samples
% % X = rand(10,500);
% % plot_array(X)
% % %% ------------
% % % plot two matrixs of 10 channels and 500 samples
% % A = rand(10,500);
% % B = rand(10,500);
% % X = {A;B};
% % plot_array(X);
% % %% ------------
% % % plot two matrixs of 5 channels and 500 samples with ylabels defined as
% % % the name of the fingers. The title will be defined by the variable TITLE
% % % and the y axis in the range [-1 1]
% % A = rand(5,500)-0.5;
% % B = rand(5,500)-0.5;
% % IxRow = {'Thumb','Index','Middle','Ring','Little'};
% % TITLE = 'Fingers Value';
% % Y_LIMITS = [-1 1];
% % X = {A;B};
% % plot_array(X,IxRow,TITLE,Y_LIMITS);
% % %% ------------
% % % plot one matrix of 5 channels and 100 samples with the first row
% % % monotonical increasing (used as x axes). And set the y limits as [-15 15];
% % A = (rand(5,500)-0.5)*15;
% % dt = 0.01; % step time
% % Time = dt:dt:length(A)*dt;
% % X = [Time;A];
% % Y_LIMITS = [-15 15];
% % plot_array(X,[],[],Y_LIMITS);
% % % 
% % %% ------------
% % % plot two matrixs of 5 channels and 100 samples with the first row
% % % monotonical increasing (used as x axes). And set the y limits as [-15 15];
% % %  And add the legend of the two signals
% % A = (rand(5,500)-0.5)*15;
% % B = (rand(5,500)-0.5)*10;
% % dt = 0.01; % step time
% % Time = dt:dt:length(A)*dt;
% % X = {[Time;A],[Time;B]};
% % Y_LIMITS = [-15 15];
% % IxLegend = {'Signal A','Signal B'};
% % F_handle=plot_array(X,[],[],Y_LIMITS,IxLegend);
% % Author:
% % Michele Barsotti, PhD student at PERCRO laboratory, 
% %                   Scuola Superiore Sant'Anna, Pisa, ITALY.        
% % Matlab 2014 is required for changing colors of cell inputs           
% 
function plot_array(X,IxRow,TITLE,Y_LIMITS,IxLegend)
LW = 1.2;
if iscell(X)
    cell_X = X;
    X = cell_X{1};
    CELL_PLOT = 1;
    fprintf('cell Plot -> each cell Input will be overlapped \n')
else
    CELL_PLOT = 0;
end
%%

if nargin<3
    TITLE =' ';
end
if ~isstr(TITLE)
%     warning('TITLE input must be a string: num2str(TITLE)')
    TITLE = num2str(TITLE);
end

%% Legend
LegendDefined = 0;
if exist('IxLegend','var')
    if ((iscellstr(IxLegend)==0)&&(length(IxLegend)~=length(cell_X)))
        fprintf('Legnth of Legend (%d), should be equal to the length of the cell (%d)',length(IxLegend),length(cell_X))
        LegendDefined = 0;
    else
        LegendDefined = 1;
    end
else
    if CELL_PLOT % metto la legenda
        LegendDefined = 1;
        for III = 1:length(cell_X)
            IxLegend{III} = ['Sig ',num2str(III)];
        end
    end     
end


%%
YlabelDefined = 0;
if exist('IxRow','var')
    if ((iscellstr(IxRow)==0)||(length(IxRow)~=size(X,1))||(isempty(IxRow)))
        disp('no y labels')
        YlabelDefined = 0;
    else
        YlabelDefined = 1;
    end
end
%%
temp_SORTX = sort(X(1,:));

if( isempty(find(all(diff(X)>0)==0, 1))&&(temp_SORTX(1)==X(1,1))&&(temp_SORTX(end)==X(1,end)))
    Time = X(1,:);
    disp('The first row is monotonical increasing and used as x axes')
    FirstRawTime = true;
else
    FirstRawTime = false;
    Time = 1:size(X,2);
    X = [Time;X];
    if YlabelDefined
        IxRow = {'Time',IxRow{:}};
    end
    if CELL_PLOT==1
        for cellCount = 1:length(cell_X)
            cell_X{cellCount} = [Time; cell_X{cellCount}];
        end
    end
    disp('The first row is not monotonical increasing. X axes are samples')
end



Nsb = size(X,1)-1;
left = 0.1;
height = 1/(Nsb+2);
width = 0.8;
bottom = 1-1.5*height;


% color for older version

Vmatlab = ver('matlab');
Vmatlab = Vmatlab.Release;
Vmatlab = str2double(Vmatlab(3:6));
ColorCodeCellPlot.Boolean = 0;
if ((Vmatlab<2014) && CELL_PLOT)
    ColorCodeCellPlot.Boolean = 1;
    ColorCodeCellPlot.Values = [0.1 0.1 0.9; 0.9 0.1 0.1; 0.1 0.9 0.1;...
                                0.9 0.1 0.9; 0.1 0.9 0.9; 0.9 0.9 0.1;];
	ColorCodeCellPlot.Values = [ColorCodeCellPlot.Values;ColorCodeCellPlot.Values*0.5];
end


% F1 = figure();
% subplot('position',[left bottom width height])
i =2; 
while i<=size(X,1)
%     ax(i-1)= subplot(Nsb,1,i-1);
    ax(i-1)=subplot('position',[left bottom width height]);
    
    if CELL_PLOT==1
        for cellCount = 1:length(cell_X)
            hold on
            if ~ColorCodeCellPlot.Boolean
            plot(Time,cell_X{cellCount}(i,:),'LineWidth',LW)
            else
                plot(Time,cell_X{cellCount}(i,:),'color',ColorCodeCellPlot.Values(cellCount,:),'LineWidth',LW)
            end
            hold off
        end
    elseif CELL_PLOT==0
        plot(Time,X(i,:),'LineWidth',LW)
    end
    if i==2;
        title(TITLE);
    end
%     if YlabelDefined==0
%         if (FirstRawTime)    
% %             ylabel(['row ',num2str(i)])        
%         else % sottraggo all'indice uno perchè ho aggiunto la linea del tempo
% %             ylabel(['row ',num2str(i-1)])
%         end

    if YlabelDefined==1
        ylabel(IxRow{i})
    end
    if i<size(X,1)
        set(gca,'Xtick',[])
    end
    if length(ax)>0
        bottom = bottom-height;
    end
    grid on
    try
        set(ax(i-1),'GridColor',[0.25 0.25 0.25])
    end
    set(ax(i-1),'YMinorTick','On')
    try
        set(ax(i-1),'XColorMode','Manual','YColorMode','Manual')
        set(ax(i-1),'XColorMode','Manual','YColorMode','Manual')
    end
    set(ax(i-1),'XColor',[1 1 1])
    if rem(i,2)==0
        set(ax(i-1),'Color',[0.95 0.95 0.95])
    end
    
    if(i==size(X,1)) 
        set(ax(i-1),'XColor',[0.1 0.1 0.1])
    end
    i = i+1;
    if nargin>3
        if ~isempty(Y_LIMITS)
            if length(Y_LIMITS)==2
                ylim([Y_LIMITS(1) Y_LIMITS(2)])
            end
        end
    end
    
end
if LegendDefined
    legend(IxLegend)
end

if (FirstRawTime)    
        xlabel('time')        
else % sottraggo all'indice uno perchè ho aggiunto la linea del tempo
        xlabel('samples')
end
linkaxes(ax,'x')
F1 = gcf();
%%
return

Nsb = size(X,1)-1;
F1 = figure();
for i=2:size(X,1)
    ax(i-1)= subplot(Nsb,1,i-1);
    plot(Time,X(i,:))
    ylabel(['row ',num2str(i)])
    if i<size(X,1)
    set(gca,'Xtick',[])
    end
    if length(ax)>1
        OldPos = get(ax(i-2),'position');
        NewPos = [OldPos(1), OldPos(2)-OldPos(4),OldPos(3),OldPos(4)]; 
        set(ax(i-1),'position',[NewPos])
    end
end
linkaxes(ax,'x')