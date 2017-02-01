function hFig = showListFig(this)
%method function for showing/creating main figure window

%% just show figure if it exists
if ~isempty(this.hListFig) && ishghandle(this.hListFig)
    figure(this.hListFig);
    hFig = this.hListFig;
    return;
end

%% Create figure

hFig = figure('Name','Molecule List',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'ToolBar','none',...
    'units','characters',...
    'position',[0,0,100,100]);
movegui(hFig,'west');

%% create table
this.hListTable = uiextras.jTable.