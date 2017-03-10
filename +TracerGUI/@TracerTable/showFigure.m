function hFig = showFigure(this)
% show/create table figure

%% If table figuer exists, just show it and return
if ~isempty(this.hFig) && ishghandle(this.hFig)
    hFig=this.hFig;
    figure(hFig);
    return;
end

%% Create Figure
hFig = figure('Name','Molecule List',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'ToolBar','none',...
    'KeyPressFcn',@(h,e) this.keypressCallback(h,e));
movegui(hFig,'west');
this.hFig=hFig;

%% Create gTable

%create context menu for table
hCtx = uicontextmenu(hFig);
uimenu(hCtx,'Label','Insert New Segment','Callback',@(~,~)this.insertNewSegment);
uimenu(hCtx,'Label','Delete Selected','Callback',@(~,~) this.deleteSelected);
uimenu(hCtx,'Label','Merge Selected','Callback',@(~,~) this.mergeSelectedSegments);
uimenu(hCtx,'Label','Split Segment','Callback',@(~,~) this.splitSelectedSegment);

[data,headers] = this.makeTableCellData;

gTable = uiextras.gTable.Table(...
    'Parent',hFig,...
    'Data',data,...
    'ColumnName',headers,...
    'GroupColumns',1,...
    'ColumnFormat',{'char','char','float','float'},...
    'ColumnEditable',[false,false,false,false],...
    'ColumnResizePolicy','last',...
    'DraggableRows',true,...
    'UIContextMenu',hCtx);

this.gTable = gTable;

set(gTable,'DragCallback',@(~,e)this.tableDragCallback(e.SourceRow,e.DestinationRow));

