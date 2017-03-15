function hFig = showFigure(this)
%show or create tracer plot figure

%% If plot figure exists, just show it and return
if ~isempty(this.hFig) && ishghandle(this.hFig)
    hFig=this.hFig;
    figure(hFig);
    return;
end

%% Create Figure
hFig = figure('Name',['AFM Traces: ',this.traceDataHandler.saveFileName],...
    'MenuBar','none',...
    'ToolBar','figure',...
    'NumberTitle','off',...
    'KeyPressFcn',@(h,e) this.keypressCallback(h,e));
movegui(hFig,'center');
this.hFig=hFig;

%% create axes
this.hAx = axes(hFig,'Position',[.01,.01,.98,.98]);



%% Try to load colormap
try
    cmap_file = fullfile(fileparts(mfilename('fullpath')), 'ZV_cmap.mat');
    c = load(cmap_file);
    this.cmap = c.cmap_zsuzsi;
catch
    this.cmap = pink(256);
end

%% Draw image
this.hImg = imagesc(this.hAx,'CData',this.traceDataHandler.im_data_flat,'HandleVisibility','off','PickableParts','none');

colormap(this.hAx,this.cmap);
axis(this.hAx,'image');

set(this.hAx,'XTick',[],'YTick',[],'Box','off');

%% colorbar
this.hCB = colorbar(this.hAx,'eastoutside');
this.hCB.Label.String = 'Height [nm]';
this.hCB.Label.FontSize = 16;
this.hCB.FontSize = 14;

%% hold on
hold(this.hAx,'on');

%% Create CRsplines
this.updateCRsplines();