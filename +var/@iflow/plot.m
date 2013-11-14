function h = plot(DC,varargin)
% PLOT Plots an iflow object
%
%   PLOT(OBJ)
%
%   PLOT([OBJ1,OBJ2,...]) overlays several plots in the same figure.
%

import misc.allowaxestogrow;

% colors/styles of the lines used for plotting matrices 2,3,4...
COLOR = [1 0 0;0 1 0;0 0 1];
LINESTYLE = {'-','--',':'};


% defaults
axis_range = [min(DC(1).Freq),max(DC(1).Freq),0,1]; % plotting range
title_str = [];         % figure title
xlabel_flag = 0;        % show range of x
ylabel_flag = 0;        % show range of y
significantonly = false;
labels = [];            % channel labels

% number of channels
[N] = size(DC(1).Flow,1);
if N<35,        % font size/type for the axes ticks labels
    font_size = 16;
    font_weight = 'Bold';
elseif N < 45,
    font_size = 10;
    font_weight = 'normal';
else
    font_size = 6;
    font_weight = 'normal';
end


% process varargin
i = 1;
while i <= length(varargin),
    argok = 1;
    if ischar(varargin{i}),
        switch lower(varargin{i}),
            % argument IDs
            case 'title',   i = i+1;    title_str = varargin{i};
            case 'xlabel',              xlabel_flag = 1;
            case 'ylabel',              ylabel_flag = 1;
            case 'font_size',   i=i+1;  font_size = varargin{i};
            case 'font_weight', i=i+1;  font_weight = varargin{i};
            case 'axis', i = i+1;       axis_range = varargin{i};
            case 'significantonly';     significantonly = true;   
            case 'labels', i = i + 1;   labels = varargin{i};
        end
    else
        argok = 0;
    end
    if ~argok,
        disp(['(@dcmatrix/plot) Ignoring invalid argument #' num2str(i+1)]);
    end
    i = i+1;
end

if isempty(labels),
   labels = cell(N,1);
   for i = 1:N
      labels{i} = num2str(i); 
   end
end

% permute the matrices to be plotted
M = cell(1,length(DC));
for i = 1:length(DC),
    M{i} = abs(DC(i).Flow);
    % threshold values below the significance
    if significantonly,
       M{i}(M{i}<DC(i).Flowsig) = 0; 
    end
    % permute for visualization
    M{i} = permute(M{i},[3 1 2]);
end


h = gcf;
% place a grid of axes in the figure and plot the matrix values
x = linspace(.15,.85,N+1); x = x(1:end);
y = linspace(.85,.15,N+1); y = y(2:end);
w = (.85-.15)/N;

h_axes = zeros(N,N);
h_plot = zeros(N,N,length(DC)-1);
h_area = zeros(N,N);
for i = 1:N
    for j = 1:N
        h_axes(i,j) = axes('Position',[x(i) y(j) w w]);

        % plot the first matrix as an area plot
        h_area(i,j) = set_area(area(DC(1).Freq,M{1}(:,j,i)));

        % plot the other matrices as lines
        hold on;
        for k = 1:length(DC)-1
            h_plot(i,j,k) = set_plot(plot(DC(1).Freq,M{k+1}(:,j,i)));
            set(h_plot(i,j,k),'Color',COLOR(k,:),'LineStyle',LINESTYLE{k});
        end

        if ~isempty(DC(1).SigTh) && ~significantonly,
            % plot the significance threshold
            set_plot(plot(DC(1).Freq,DC(1).SigTh(end)*ones(1,size(M{1},1)),'--r'));            
        end

        % store info about current sub-plot
        tmp.xlabel = labels{i};
        tmp.ylabel = labels{j};
        set(h_axes(i,j),'UserData',tmp);
        axis(axis_range);
        set_axes(h_axes(i,j));

        % take care of the channel labels
        if j == N
            set_label(xlabel(h_axes(i,j),labels{i}),font_size,font_weight);
            if xlabel_flag && i==1,
                set_xaxis(h_axes(i,j),[DC(1).Freq(1) DC(1).Freq(end)]);
            end
        end
        if i == 1
            set_label(ylabel(h_axes(i,j),labels{j}),font_size,font_weight);
            if ylabel_flag && j==N,
                set_yaxis(h_axes(i,j),[0 1]);
            end
        end
    end % end of inner channels iterator
end % end of outer channels iterator

set_title(annotation('textbox',[.1,0.9,.8,.1]),title_str);


allowaxestogrow(h,DC.Freq,linspace(0,1,10));

return;







%%%%%%%% Sub-functions below:



function [h] = set_xaxis(h,range)
% Set xaxis properties
labels = num2str(range(:));
set(h,'XTick',range,'XTickLabel',labels);
return;

function [h] = set_yaxis(h,range)
% Set yaxis properties
labels = num2str(range(:));
set(h,'YTick',range,'YTickLabel',labels);
return;


function [h] = set_label(h,font_size,font_weight)
% Set label properties
if nargin < 3,
    font_weight = 'bold';
end
if nargin < 2,
    font_size = 10;
end
set(h,...
    'FontWeight',font_weight,...
    'FontSize',font_size);

return;

function h_plot = set_area(h_plot)
% Set area properties
set(h_plot,...
    'LineStyle','none');

return;

function h_plot = set_plot(h_plot)
% Set plot properties
set(h_plot,...
    'LineWidth',2.5);

return;

function h = set_title(h,title_str)
% Set title properties
set(h, ...
    'VerticalAlignment','middle',...
    'HorizontalAlignment','center',...
    'String',title_str,...
    'FontWeight','bold',...
    'FontSize',14,...
    'LineStyle','none');

return;

function h = set_axes(h)
% Set axes properties
set(h, ...
    'LineWidth',1,...
    'XTickLabel',[],...
    'YTickLabel',[],...
    'XTick',[],...
    'YTick',[])
return

