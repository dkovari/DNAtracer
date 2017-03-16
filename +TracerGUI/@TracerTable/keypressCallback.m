function keypressCallback(this,~,e)
%handle keypress on table



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


%NOTE: Keypress not working with table right now.

%'in kp'

%% Delete/backspace
if strcmp(e.Key,'backspace')||strcmp(e.Key,'delete')
    %'de'
    this.deleteSelected();
    return;
end