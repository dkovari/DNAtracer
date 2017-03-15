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
        
        MoleculeCR=struct('SegCR',{}); %struct holding CRspline handles
        
        saveNameListener; %listener for changes to file name
        dataChangeListener;
    end
    
    %% constructor/destructor
    methods
        function this = TracerPlot(mainController)
            this.mainController = mainController;
            this.traceDataHandler = mainController.traceDataHandler;
            
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
    end
    
end

