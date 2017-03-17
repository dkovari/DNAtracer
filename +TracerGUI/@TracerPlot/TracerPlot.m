classdef TracerPlot < handle
    %TracerPlot Class for handling tracer plot
    %   Detailed explanation goes here
    
    properties
        mainController; %handle to main controller class
        traceDataHandler; %handle to traceDataHandler, obtained from mainControllerClass during construction
        
        hFig
        hAx
        hImg
        cmap
        hCB
        
        colorGen = @(n) lines(n);
        DEFAULT_LINE_WIDTH = 1.5;
        DEFAULT_MARKER_SIZE = 6;
        SELECTED_LINE_WIDTH = 2.5;
        SELECTED_LINE_STYLE = '-';
        SELECTED_LINE_COLOR = 'r';
        SELECTED_MARKER_SIZE = 8;
        SELECTED_MARKER_COLOR = 'r';
        
        MoleculeCR=struct('SegCR',{}); %struct holding CRspline handles
        
        saveNameListener; %listener for changes to file name
        dataChangeListener;
    end
    
    %% constructor/destructor
    methods
        function this = TracerPlot(mainController)
            this.mainController = mainController;
            this.traceDataHandler = mainController.traceDataHandler;
            
            %% associate data change event listeners
            this.saveNameListener = addlistener(this.traceDataHandler,'saveFileName','PostSet',@(h,e) this.updateFigureName(h,e));
            this.dataChangeListener = addlistener(this.traceDataHandler,'DataChanged',@(~,~) this.updateCRsplines);
            
        end
        function delete(this)
            try
                delete(this.saveNameListener);
            catch
            end
            try
                delete(this.dataChangeListener);
            catch
            end
            try
                for n=1:numel(this.MoleculeCR)
                    for j=1:numel(this.MoleculeCR.CRseg)
                        delete(this.MoleculeCR(n).CRseg(j));
                    end
                end
            catch
            end
            
            try
                delete(this.hFig)
            catch
            end
        end
    end
    
    %% others
    methods
        hFig = showFigure(this);
        function updateFigureName(this,~,~)
            this.hFig.Name = ['AFM Traces: ',this.traceDataHandler.saveFileName];
        end
        updateCRsplines(this)
        uiPlotEditCallback(this,mol_id,seg_id);
        setSelectedCRsplines(this);
        keypressCallback(this,h,e);
        splitSegment(this,Molecule,Segment);
        mergeSegments(this,SegList)
        SegData = UIcreateNewSegment(this);
    end
    
end

