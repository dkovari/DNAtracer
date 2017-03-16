classdef TracerMain < handle
    %TRACERMAIN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        traceDataHandler %object holding all the processed data
        
        traceTable;
        tracePlot
    end
    
    properties (SetAccess = private)
        selectedMoleculeSegments = struct('Molecule',{},'Segment',{}); %Column1=moleculeID, Column2=segmentID
    end
    
    properties %GUI handles
        hMainFig; %handle to main window
    end
    
    %% main figure menu hghandles
    properties(Access=private)
        hMenu_Save;
        hMenu_Undo;
    end
    
    %% Event listeners
    properties(Access=private)
        saveNameListener;
    end
    
    %% Creation/deletion methods
    methods %creation/deletion methods
        function this = TracerMain(data,filepath)
            
            if nargin<1
                data = [];
            end
            if nargin<2
                filepath = [];
            end
            
            %% create data handler
            this.traceDataHandler = TracerGUI.TracerData(data,filepath);
            
            %% associate event listeners
            this.saveNameListener = addlistener(this.traceDataHandler,'saveFileName','PostSet',@(~,~) this.updateFigureName);
            addlistener(this.traceDataHandler,'SaveStatusChanged',@(~,~) this.saveStateChangeCallback);
            addlistener(this.traceDataHandler,'undoBufferAvailable','PostSet',@(~,~) this.updateUndoAvailable());
            
            %% Create Main Menu
            this.hMainFig = this.showMainFig();
            
            %% Create Data manipulation objects
            % Note: object will associate event listeners with the
            % dataChange event thrown by traceDataHandler. Create the
            % objects in reverse-order of callback execution.
            
            %% Create plot of traces
            %Since plotting is the slowest, create the plot first so that
            %the other callbacks appear to respond more naturally
            this.tracePlot = TracerGUI.TracerPlot(this);
            this.tracePlot.showFigure();
            
            %% Create table of traces
            this.traceTable = TracerGUI.TracerTable(this);
            this.traceTable.showFigure();
            
            
        end
        function delete(this)
            try
                delete(this.saveNameListener);
            catch
            end
            
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
            elseif strcmp(answer,'Yes')
                this.saveFileAs();
            end

            %open new data handler
            this.traceDataHandler.loadData();
        end
        function saveFile(this)
            this.traceDataHandler.saveData();
        end
        function saveFileAs(this)
            this.traceDataHandler.saveDataAs();
        end
        function closeFile(this)
            if this.traceDataHandler.dataChangedSinceSave
                answer = questdlg('Save file before exiting?','Save?','Yes','No','Cancel','Yes');
            if strcmp(answer,'Cancel')
                return;
            elseif strcmp(answer,'Yes')
                this.saveFile(this);
            end
            end
            delete(this);
        end
    end
    %% Window menu
    methods
        showTraceTable(this);
        showTracePlot(this);
    end
    %% Inter-GUI Data operations
    methods
        splitSegment(this,Mol,Seg);
    end
    %% Event Callbacks
    methods
        function updateFigureName(this)
            try
                this.hMainFig.Name = ['AFM Traces: ',this.traceDataHandler.saveFileName];
            catch
            end
        end
        
        keypressCallback(this,obj,event);
        
        function updateUndoAvailable(this)
            if this.traceDataHandler.undoBufferAvailable
                this.hMenu_Undo.Enable='on';
            else
                this.hMenu_Undo.Enable='off';
            end
            
        end
        
        function saveStateChangeCallback(this)
            %'Save State Changed'
            set(this.hMenu_Save,'Enable',tf_2_on_off(this.traceDataHandler.dataChangedSinceSave));
        end
        
        selecedMoleculeChangedViaTable(this,Molecules,Segments);
        
        function undoDataChange(this)
            this.traceDataHandler.undoLastOp();
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