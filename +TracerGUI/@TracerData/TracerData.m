classdef TracerData < handle
    %TRACERDATA Class for holding and manipulating molecule trace data
    %   Detailed explanation goes here
    
    properties
        
    end
    
    properties (Access=private)
        data;
        
    end
    
    properties (SetAccess=private)
        dataChangedSinceSave = false;
        saveFileName;
        saveFileDir;
    end
    
    events
    end
    
    %% __STRUCTORs
    methods 
        function this = TracerData(data)
            if nargin>1 %cTor was passed some data
                this.loadData(data);
            else
            end
                
        end %function TracerData
        
        function delete(this)
            
        end %function delete(this)
    end
    
    %% file operations
    methods
        %% Load
        function loadData(this,data)
            
            dataChangedSinceSave = false;
            %% Get and Load data from file
            persistent LastDir;

            if nargin<2 || isempty(data) %%Nothing Specified, prompt for gui selection
                %Ask to load from workspace or file
                
                %file
                [FileName,PathName] = uigetfile({'*.mat','MATLAB Data';'*.*','All Files (*.*)'},...
                                                'Select TraceData File',...
                                                fullfile(LastDir,'*.mat'));
                if FileName == 0
                    return;
                end
                LastDir = PathName;
                data = load(fullfile(PathName,FileName));
            elseif isstruct(data) %struct specified
                FileName = '';
                PathName = '';
                dataChangedSinceSave = true;
            elseif ischar(data)
                [PathName,FileName,ext] = fileparts(data);
                FileName = [FileName,ext];
                
                data = load(data);
            else
                error('unexpected type');
            end
            
            %% validate data
            if ~isstruct(data)
                error('input argument must be a file path or a struct containing data');
            end
            
            %% Store the data and other parameters in this
            this.data = data;
            this.dataChangedSinceSave = dataChangedSinceSave;
            this.saveFileName = FileName;
            this.saveFileDir = PathName;
            
        end
        %% Save
        function saveData(this,filepath)
            if isempty(this.data)
                warning('Data not loaded. Nothing to save');
                return;
            end
            
            %get/process filepath if needed
            persistent LastDir;
            if nargin>1 && ~isempty(filepath)
                [this.saveFileDir,fn,ext] = fileparts(filepath);
                this.saveFileName = [fn,ext];
            elseif isempty(this.saveFileName)
                [FileName,FileDir] = uiputfile({'*.mat','MATLAB Data';'*.*','All Files (*.*)'},...
                                                'Select TraceData File',...
                                                fullfile(LastDir,'*.mat'));
                if FileName==0
                    warning('canceled save. not saving');
                    return;
                end
                this.saveFileName = FileName;
                this.saveFileDir = FileDir;
                LastDir = FileDir;
            end
            
            %Save
            save(fullfile(this.saveFileDir,this.saveFilePath),'-mat','-struct',this.data);
            
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = false;
            
            %% notify listeners
            if wasOutdated
                %notify listeners
            end
        end
        %% SaveAs
        function saveDataAs(this,filepath)
            if isempty(this.data)
                warning('Data not loaded. Nothing to save');
                return;
            end
            
            %get/process filepath if needed
            persistent LastDir;
            if nargin>1 && ~isempty(filepath)
                [this.saveFileDir,fn,ext] = fileparts(filepath);
                this.saveFileName = [fn,ext];
            else
                if ~isempty(this.saveFileDir)
                    LastDir = this.saveFileDir;
                end
                [FileName,FileDir] = uiputfile({'*.mat','MATLAB Data';'*.*','All Files (*.*)'},...
                                                'Select TraceData File',...
                                                fullfile(LastDir,'*.mat'));
                if FileName==0
                    warning('canceled save. not saving');
                    return;
                end
                this.saveFileName = FileName;
                this.saveFileDir = FileDir;
                LastDir = FileDir;
            end
            
            %Save
            save(fullfile(this.saveFileDir,this.saveFilePath),'-mat','-struct',this.data);

            this.dataChangedSinceSave = false;
            
            %% notify listeners, even if data hasn't changed, because we changed the file

        end
    end
    
    %% Publicly Accessible Methods for data interaction
    methods
        %% Remove Molecule
        function removeMolecule(this,mol_id)
            
            %% notify listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
            end
        end
        
        %% Split Molecule
        function splitMolecule(this,mol_id,new_segment_list)
            
            %% notify listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
            end
        end
        
        %% Merge Molecules
        function mergeMolecule(this,mol_list)
            
            %% notify listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
            end
        end
        %% Move Segment to different molecule
        function moveSegmentMolecule(this,src_molecule,src_segments,dest_molecule,dest_seg_index)
            
            %% notify listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
            end
        end
        
        %% Reorder Segments
        function reorderSegments(this,molecule,new_segment_order)
            
            %% notify listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
            end
        end
        %% Remove Segment
        function removeSegment(this,molecule,segments)
            %% notify listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
            end
        end
        %% Add Segment
        function addSegment(this,molecule,segment_nodes,new_index)
            %% notify listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
            end
        end
        %% Join Segments
        function joinSegments(this,molecule1,segment1,molecule2,segment2,segment1_dir,segment2_dir)
            %% notify listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
            end
        end
        %% Segment Nodes
        function nodes = getSegmentNodes(this,molecule,segment)
        end
        function setSegmentNodes(this,molecule,segment,nodes)
            %% notify listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
            end
        end

    end
    
end

