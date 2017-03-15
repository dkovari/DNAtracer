classdef TracerTable < handle
    %TracerTable Class for creating and handling the molecule list
    %   Detailed explanation goes here
    
    properties
        mainController; %handle to main controller class
        traceDataHandler; %handle to traceDataHandler, obtained from mainControllerClass during construction
        hFig
        gTable
        dataChangeListener;
        hMenu_Split;
        hMenu_Merge;
    end
    
    %% __structors
    methods
        %ctor
        function this = TracerTable(mainController)
            %% store handles
            this.mainController = mainController;
            this.traceDataHandler = mainController.traceDataHandler;
            
            %% associate events
            this.dataChangeListener = addlistener(this.traceDataHandler,'DataChanged',@(~,~)this.dataUpdateCallback);
            
        end
        %dtor
        function delete(this)
            try 
                delete(this.dataChangeListener)
            catch
            end
            try
                delete(this.hFig)
            catch
            end
        end
    end
    
    %% gui methods
    methods
        hFig = showFigure(this);
        tableDragCallback(this,src_row,dest_row);
        mergeSelectedSegments(this);
        splitSelectedSegment(this);
        deleteSelected(this);
        insertNewSegment(this);
        keypressCallback(this,h,e);
    end
    
    methods
        selectionCallback(this,h,e);
    end
    
    methods
        dataUpdateCallback(this);
        [data,headers] = makeTableCellData(this);
    end
    
end

