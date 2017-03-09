function hFig = showMainFig(this)
%method function for showing/creating main figure window

%% just show figure if it exists
if ~isempty(this.hMainFig) && ishghandle(this.hMainFig)
    figure(this.hMainFig);
    hFig = this.hMainFig;
    return;
end


%% Figure does not exist, create it

hFig = figure('Name','DNA Tracer',...
    'MenuBar','none',...
    'NumberTitle','off',...
    'ToolBar','none',...
    'position',[0,0,500,0],...
    'resize','off');
movegui(hFig,'northwest');

%% Create menu items

% File Menu
hMenu_File = uimenu(hFig,'Label','File');
uimenu(hMenu_File,'Label','Open');
uimenu(hMenu_File,'Label','Save');
uimenu(hMenu_File,'Label','Save As...');
uimenu(hMenu_File,'Label','Close');


%Windows menu
hMenu_Win = uimenu(hFig,'Label','Windows');
uimenu(hMenu_Win,'Label','List');
uimenu(hMenu_Win,'Label','View');
uimenu(hMenu_Win,'Label','Controls');


