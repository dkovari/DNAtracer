classdef TracerMain < handle
    %TRACERMAIN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        traceDataHandler %object holding all the processed data
        selectedMoleculeSegments; %Column1=moleculeID, Column2=segmentID
        
        traceTable;
        tracePlot
    end
    
    properties %GUI handles
        hMainFig; %handle to main window
    end
    
    %% main figure menu hghandles
    properties(Access=private)
        hMenu_Save;
    end
    
    methods %creation/deletion methods
        function this = TracerMain(data)
            
            if nargin<1
                data = [];
            end
            
            %% create data handler
            this.traceDataHandler = TracerGUI.TracerData(data);
            
            %% associate event listeners
            addlistener(this.traceDataHandler,'SaveStatusChanged',@(~,~)this.saveStateChangeCallback);
            
            %% Create Main Menu
            this.hMainFig = this.showMainFig();
            
            %% Create table of traces
            this.traceTable = TracerGUI.TracerTable(this);
            this.traceTable.showFigure(this);
            
            %% Create plot of traces
            this.tracePlot = TracerGUI.TracerPlot(this);
            this.tracePlot.showFigure(this);
            
            
        end
        function delete(this)
            try
                delete(this.hMainFig);
            catch
            end
            
            try
                delete(this.traceTable);
                delete(this.tracePlot);
                delete(this.traceDataHandler);
            catch
            end
        end
    end
    
    %% Private Methods
    methods
        hFig = showMainFig(this)
    end
    
    %% Main Figure File Callbacks
    methods
        function openFile(this)
            answer = questdlg('Save current data before opening new file?','Save?','Yes','No','Cancel','Yes');
            if strcmp(answer,'Cancel')
                return;
            elseif strcmp(anwer,'Yes')
                this.saveFileAs(this);
            end

            %open new data handler
            this.traceDataHandler.loadData();
        end
        function saveFile(this)
            this.traceDataHandler.saveFile();
        end
        function saveFileAs(this)
            this.traceDataHandler.saveFileAs();
        end
        function closeFile(this)
            if this.traceDataHandler.dataChangedSinceSave
                answer = questdlg('Save file before exiting?','Save?','Yes','No','Cancel','Yes');
            if strcmp(answer,'Cancel')
                return;
            elseif strcmp(anwer,'Yes')
                this.saveFile(this);
            end
            end
            delete(this);
        end
    end
    
    %% Event Callbacks
    methods
        keyPressCallback(this,obj,event)
        function saveStateChangeCallback(this)
            set(this.hMenu_Save,'Enable',tf_2_on_off(this.traceDataHandler.dataChangedSinceSave));
        end
    end
end


function str=tf_2_on_off(tf)
    if tf
        str = 'on';
    else
        str = 'off';
    end
end