classdef TracerMain
    %TRACERMAIN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        traceData %struct holding all the processed data
        SaveUpToDate = false;
    end
    
    properties %GUI handles
        hMainFig; %handle to main window
        
        hListFig; %handle to list window
        hListTable; %handle to list table
        
        hViewFig; %handle to view window
        hControlFig; %handle to controls window
    end
    
    methods %creation/deletion methods
        function this = TracerMain(data)
            persistent LastDir;
            if nargin<1 || isempty(data)
                %Ask to load from workspace or file
                
                %file
                [FileName,PathName] = uigetfile({'*.mat','MATLAB Data';'*.*','All Files (*.*)'},'Select TraceData File',fullfile(LastDir,'*.mat'));
                if FileName == 0
                    return;
                end
                LastDir = PathName;
                filename = fullfile(PathName,FileName);
                data = load(filename);
            elseif ischar(data)
                data = load(data);
            end
            
            %% validate data
            if ~isstruct(data)
                error('input argument must be a file path or a struct containing data');
            end
            
            this.TraceData = data;
            this.SaveUpToDate = true;
            
            %% Create Main Menu
            this.hMainFig = this.showMainFig();
            
            %% Create List Window
            this.hListFig = this.showListFig();
            
            
        end
    end
    
    %% Private Methods
    methods
        hFig = showMainFig(this)
        hFig = showListFig(this)
        hFig = showViewFig(this)
        hFig = showControlFig(this)
    end
    
end

