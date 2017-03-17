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
    'ToolBar','none',...
    'NumberTitle','off',...
    'KeyPressFcn',@(h,e) this.keypressCallback(h,e));
movegui(hFig,'west');
this.hFig=hFig;

%% Create gTable

%create context menu for table
hCtx = uicontextmenu(hFig);
uimenu(hCtx,'Label','Create New Molecule','Callback',@(~,~) this.createNewMolecule);
uimenu(hCtx,'separator','on','Label','Insert New Segment Before','Callback',@(~,~)this.insertNewSegmentBeforeSelected);
uimenu(hCtx,'Label','Insert New Segment After','Callback',@(~,~)this.insertNewSegmentAfterSelected);
uimenu(hCtx,'separator','on','Label','Delete Selected','Callback',@(~,~) this.deleteSelected);
this.hMenu_Merge = uimenu(hCtx,'Label','Merge Selected','Callback',@(~,~) this.mergeSelectedSegments);
this.hMenu_Split = uimenu(hCtx,'Label','Split Segment','Callback',@(~,~) this.splitSelectedSegment);

[data,headers] = this.makeTableCellData;

gTable = uiextras.gTable.Table(...
    'Parent',hFig,...
    'Data',data,...
    'ColumnName',headers,...
    'GroupColumns',1,...
    'ColumnFormat',{'char','char','float','float'},...
    'ColumnEditable',[false,false,false,false],...
    'ColumnResizePolicy','last',...
    'SelectionMode','discontiguous',...
    'DraggableRows',true,...
    'UIContextMenu',hCtx);

this.gTable = gTable;

set(gTable,'DragCallback',@(~,e)this.tableDragCallback(e.SourceRow,e.DestinationRow));
set(gTable,'CellSelectionCallback',@(~,e) this.selectionCallback(gTable,e));

