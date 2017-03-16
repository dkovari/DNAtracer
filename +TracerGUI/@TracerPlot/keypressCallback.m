function keypressCallback(this,~,e)
%handle keypress events on plot

%% Handle ctrl-z/cmd-z
if strcmp(e.Key,'z')
    switch computer('arch')
        case 'win64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'control')
                this.mainController.undoDataChange();
                return;
            end
        case 'maci64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'command')
                this.mainController.undoDataChange();
                return;
            end
        case 'glnxa64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'control')
                this.mainController.undoDataChange();
                return;
            end
    end
end

%% Reset Zoom with ctr-0/cmd-0
if (strcmp(e.Key,'0')||strcmp(e.Key,'numpad0'))&&strcmp(e.Character,'0')
    switch computer('arch')
        case 'win64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'control')
                zoom(this.hFig,'out');
                return;
            end
        case 'maci64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'command')
                zoom(this.hFig,'out');
                return;
            end
        case 'glnxa64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'control')
                zoom(this.hFig,'out');
                return;
            end
    end
end
%% Zoom in with ctrl-=/cmd-= or ctrl-+/cmd-+
if strcmp(e.Key,'equal')||strcmp(e.Key,'add')
    switch computer('arch')
        case 'win64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'control')
                zoom(this.hFig,1.2);
                return;
            end
        case 'maci64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'command')
                zoom(this.hFig,1.2);
                return;
            end
        case 'glnxa64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'control')
                zoom(this.hFig,1.2);
                return;
            end
    end
end

%% Zoom out with ctrl-'-'/cmd-'-'
if strcmp(e.Key,'hyphen')||strcmp(e.Key,'subtract')
    switch computer('arch')
        case 'win64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'control')
                zoom(this.hFig,1/1.2);
                return;
            end
        case 'maci64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'command')
                zoom(this.hFig,1/1.2);
                return;
            end
        case 'glnxa64'
            if numel(e.Modifier)==1 && strcmp(e.Modifier{1},'control')
                zoom(this.hFig,1/1.2);
                return;
            end
    end
end