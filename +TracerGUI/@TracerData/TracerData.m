classdef TracerData < handle
    %TRACERDATA Class for holding and manipulating molecule trace data
    %   Detailed explanation goes here
    
    properties(Dependent)
        MoleculeData;
        im_data
        im_data_flat
        NS_data
        
    end
    
    properties (SetAccess=private)
        data;
        % data Structure:
        %  data.NS_data
        %       .im_data
        %       .im_data_flat
        %       .im_flat
        %       .bin_data
        %       .RidgeImage
        %       .MoleculeData().
        %           .SubImg
        %           .PixelIdxList
        %           .Segment()
        %               .XY
        %               .cspline
        %               .CRnodes
        %                   .X
        %                   .Y
        
        undoDataBuffer
    end
    
    properties(SetAccess=private, SetObservable=true)
        undoBufferAvailable = false;
        saveFileName;
        saveFileDir;
    end
    
    properties (SetAccess=private)
        dataChangedSinceSave = false;
    end
    
    events
        SaveStatusChanged;
        DataChanged;
    end
    
    %% __STRUCTORs
    methods 
        function this = TracerData(data,filepath)
            if nargin<2
                filepath = [];
            end
            if nargin>0 %cTor was passed some data
                this.loadData(data,filepath);
            else
                %make an object without data
            end
                
        end %function TracerData
        
        function delete(this)
            
        end %function delete(this)
    end
    
    %% file operations
    methods
        %% Load
        function loadData(this,data,filepath)
            
            dataChangedSinceSave = false;
            %% Load data
            persistent LastDir;

            if nargin<2 || isempty(data) %Nothing Specified, prompt for gui selection
                %Ask to load from workspace or file
                
                %file
%                 [FileName,PathName] = uigetfile({'*.mat','MATLAB Data';'*.*','All Files (*.*)'},...
%                                                 'Select TraceData File',...
%                                                 fullfile(LastDir,'*.mat'));
                num_ext = sprintf('*.%03d;',1:999);
                num_ext(end) = [];
                [FileName,PathName] = uigetfile({['*.mat;',num_ext],'TraceData & Nanoscope Files (*.mat,*.###)';...
                                                '*.mat','TraceData File (*.mat)';...
                                                num_ext,'Nanoscope Files (*.###)';...
                                                '*.*','All Files (*.*)'},...
                                                'Select TraceData or Nanoscope Image File',...
                                                fullfile(LastDir,'*.mat'));
                %do nothing if canceled
                if FileName == 0
                    return;
                end
                LastDir = PathName;
                
                [~,~,ext] = fileparts(FileName);
                switch lower(ext)
                    case '.mat'
                        data = load(fullfile(PathName,FileName));
                    otherwise
                        if isnan(str2num(ext(2:end)))
                            warndlg('Selected file was not a *.mat data file, nor *.00x Nanoscope file.\n Attempting to load as MATLAB Data','modal');
                            data = load(fullfile(PathName,FileName),'-mat');
                        else
                            data = TracerGUI.TracerData.processAFMImage(fullfile(PathName,FileName));
                            dataChangedSinceSave = true;
                            FileName = '';
                        end
                end
     
            elseif isstruct(data) %struct specified
                if nargin<3 || isempty(filepath)
                    FileName = '';
                    PathName = '';
                else
                    [PathName,FileName,ext] = fileparts(filepath);
                    FileName = [FileName,ext];
                end
                dataChangedSinceSave = true;
            elseif ischar(data) %specified filepath
                [PathName,FileName,ext] = fileparts(data);
                FileName = [FileName,ext];
                switch lower(ext)
                    case '.mat'
                        data = load(fullfile(PathName,FileName));
                    otherwise
                        if isnan(str2num(ext(2:end)))
                            warndlg('Selected file was not a *.mat data file, nor *.00x Nanoscope file.\n Attempting to load as MATLAB Data','modal');
                            data = load(fullfile(PathName,FileName),'-mat');
                        else
                            data = TracerGUI.TracerData.processAFMImage(fullfile(PathName,FileName));
                            dataChangedSinceSave = true;
                            FileName = '';
                        end
                end
            else
                error('unexpected input type');
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
            
            %% notify data listeners
            this.notify('DataChanged');
            
            %% notify listeners
            this.notify('SaveStatusChanged');

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
                
                if ~isempty(this.saveFileDir)
                    LastDir = this.saveFileDir;
                end
                
                [FileName,FileDir] = uiputfile({'*.mat','MATLAB Data';'*.*','All Files (*.*)'},...
                                                'Save TraceData File As...',...
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
            data = this.data;
            save(fullfile(this.saveFileDir,this.saveFileName),'-mat','-struct','data');
            
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = false;
            
            %% notify listeners
            if wasOutdated
                %notify listeners
                this.notify('SaveStatusChanged');
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
            data = this.data;
            save(fullfile(this.saveFileDir,this.saveFileName),'-mat','-struct','data');

            this.dataChangedSinceSave = false;
            
            %% notify listeners, even if data hasn't changed, because we changed the file
            this.notify('SaveStatusChanged');
        end
    end
    
    %% Publicly Accessible Methods for data modification
    methods
        %% Undo
        function undoLastOp(this)
            if ~this.undoBufferAvailable || isempty(this.undoDataBuffer)
                warning('The undo buffer does not contain data. Nothing will be changed');
                this.undoBufferAvailable = false;
            end
            
            this.data = this.undoDataBuffer;
            this.undoDataBuffer = [];
            this.undoBufferAvailable = false;
            
            %% notify data listeners
            this.notify('DataChanged');
            %% notify save listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
                this.notify('SaveStatusChanged');
            end
            
        end
        
        %% insert new segment
        function insertSegment(this,SegList,SegData)
            %insert new segment data
            %SegList specifies insert locations
            %SegData is struc array holding the new data
            
            %% verify data
            if numel(SegList)~= numel(SegData)
                error('SegList and SegData must be same size');
            end
            %% create undo buffer
            this.undoDataBuffer = this.data;
            this.undoBufferAvailable = true;
            
            %% insert data
            for n=min([SegList.Molecule]):max([SegList.Molecule])
                ind = find(n==[SegList.Molecule]);
                if ~isempty(ind)
                    if n>numel(this.data.MoleculeData)
                        this.data.MoleculeData(n).Segment = struct('XY',{},'cspline',{},'CRnodes',{});
                    end
                    %sort ind by decreasing segment
                    [~,I] = sort([SegList(ind).Segment],'descend');
                    ind = ind(I); %shuffle ind to new order
                    %insert the data
                    nSeg = numel(this.MoleculeData(n).Segment);
                    for i = ind
                        seg = SegList(i).Segment;
                        
                        if seg>nSeg
                            this.data.MoleculeData(n).Segment(seg) = SegData(i);
                        else
                            this.data.MoleculeData(n).Segment = ...
                                [this.data.MoleculeData(n).Segment(1:seg-1),...
                                SegData(i),...
                                this.data.MoleculeData(n).Segment(seg:end)];
                        end
                    end
                end
            end
            
            %% notify data listeners
            this.notify('DataChanged');
            
            %% notify save listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
                this.notify('SaveStatusChanged');
            end
        end
        
        %% Split Molecule
        function splitMolecule(this,mol_id,new_segment_list)
            %check that there is data
            if isempty(this.data)
                return;
            end
            %create undo buffer
            this.undoDataBuffer = this.data;
            this.undoBufferAvailable = true;
            
            %split
            mol_dat1 = this.data.MoleculeData(mol_id);
            
            mol_dat2 = mol_dat1;
            
            mol_dat1.Segment(new_segment_list) = [];
            mol_dat2.Segment = mol_data2.Segment(new_segment_list);
            
            
            this.data.MoleculeData = [this.data.MoleculeData(1:mol_id-1),...
                                        mol_dat1,...
                                        mol_dat2,...
                                        this.data.MoleculeData(mol_id+1:end)];

            
            %% notify data listeners
            this.notify('DataChanged');
            
            %% notify save listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
                this.notify('SaveStatusChanged');
            end
        end
        
        %% Move segments to new molecule
        function newSegList = newMoleculeFromSegments(this,SegList)
            %% create undo buffer
            this.undoDataBuffer = this.data;
            this.undoBufferAvailable = true;
            
            %% Create new molecule
            NewMolecule = struct('SubImg',[],'PixelIdxList',[],...
                'Segment',this.data.MoleculeData(SegList(1).Molecule).Segment(SegList(1).Segment));
            for n=2:numel(SegList)
                NewMolecule.Segment(n) = this.data.MoleculeData(SegList(n).Molecule).Segment(SegList(n).Segment);
            end
            
            %% delete segments
            for n=min([SegList.Molecule]):max([SegList.Molecule])
                ind = find(n==[SegList.Molecule]);
                if ~isempty(ind)
                    seg = [SegList(ind).Segment];
                    this.data.MoleculeData(n).Segment(seg) = [];
                end
            end
            
            %% Insert New Molecule
            new_mol = max([SegList.Molecule])+1;
            this.data.MoleculeData = [this.data.MoleculeData(1:new_mol-1),...
                                        NewMolecule,...
                                        this.data.MoleculeData(new_mol:end)];
            
            %remove empty molecules
            for n=numel(this.data.MoleculeData):-1:1
                if isempty(this.data.MoleculeData(n).Segment)
                    this.data.MoleculeData(n) = [];
                end
            end
            
            for n=numel(SegList):-1:1
                newSegList(n).Molecule = new_mol;
                newSegList(n).Segment = n;
            end
            
                                  
            %% notify data listeners
            this.notify('DataChanged');
            
            %% notify save listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
                this.notify('SaveStatusChanged');
            end
        end
        
        %% Merge Molecules
        function new_idx = mergeMolecule(this,mol_list)
            
            %check that there is data
            if isempty(this.data)
                return;
            end
            %create undo buffer
            this.undoDataBuffer = this.data;
            this.undoBufferAvailable = true;
            
            %% merge
            
            %new molecule will be stored in lowest index
            [new_idx,ind] = min(mol_list);
            
            
            mol_dat = this.data.MoleculeData(mol_list(1));
            for n=2:numel(mol_list)
                %update subimg
                new_mol = this.data.MoleculeData(mol_list(n));
                mol_dat.SubImg(1,1) = min(mol_dat.SubImg(1,1),new_mol.SubImg(1,1));
                mol_dat.SubImg(1,2) = min(mol_dat.SubImg(1,2),new_mol.SubImg(1,2));
                mol_dat.SubImg(2,1) = max(mol_dat.SubImg(2,1),new_mol.SubImg(2,1));
                mol_dat.SubImg(2,2) = max(mol_dat.SubImg(2,2),new_mol.SubImg(2,2));
                %update pixel list
                mol_dat.PixelIdxList = [mol_dat.PixelIdxList;new_mol.PixelIdxList];
                %Add segments
                mol_dat.Segment = [mol_dat.Segment,new_mol.Segment];
            end
            
            %remove merged molecules
            mol_list(ind) = [];
            this.data.MoleculeData(mol_list) = [];
            
            %store in lowest index
            this.data.MoleculeData(new_idx) = mol_data;
            
            
            %% notify data listeners
            this.notify('DataChanged');
            
            %% notify save listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
                this.notify('SaveStatusChanged');
            end
        end
        
        %% Move Segment(s) to different position or molecule
        function moveSegment(this,SrcList,Dest)%src_molecule,src_segments,dest_molecule,dest_seg_index)
            
            %% verify inputs
            if numel(Dest)>1
                error('Can only move to a single location index');
            end
            
            %check that we are actually moving something
            if numel(SrcList)==1 && SrcList.Molecule==Dest.Molecule && SrcList.Segment==Dest.Segment
                return;
            end
                        
            %% create undo buffer
            this.undoDataBuffer = this.data;
            this.undoBufferAvailable = true;
            
            %% move segment
            for n=numel(SrcList):-1:1
                newBlock(n) = this.data.MoleculeData(SrcList(n).Molecule).Segment(SrcList(n).Segment);
            end
            this.data.MoleculeData(Dest.Molecule).Segment = ...
                [this.data.MoleculeData(Dest.Molecule).Segment(1:Dest.Segment-1),...
                 newBlock,...
                 this.data.MoleculeData(Dest.Molecule).Segment(Dest.Segment:end)];
             
             %% clear originals
             nSeg = numel(SrcList);
             for n=1:numel(this.data.MoleculeData)
                 
                 ind = find([SrcList.Molecule]==n);
                 
                 if n~=Dest.Molecule
                     this.data.MoleculeData(n).Segment([SrcList(ind).Segment]) = [];
                 else
                     Segs = [SrcList(ind).Segment];
                     before = Segs(Segs<Dest.Segment);
                     after = Segs(Segs>=Dest.Segment)+nSeg;
                     
                     this.data.MoleculeData(n).Segment(before) = [];
                     this.data.MoleculeData(n).Segment(after) = [];
                 end
                 
                 SrcList(ind) = [];
             end
            
            %% notify data listeners
            this.notify('DataChanged');
            
            %% notify save listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
                this.notify('SaveStatusChanged');
            end
        end
        
        %% Remove Segment
        function removeSegment(this,SegList)
            
            %create undo buffer
            this.undoDataBuffer = this.data;
            this.undoBufferAvailable = true;
            
            %% Delete segments
            
            for n=1:max([SegList.Molecule])
                Segs = [SegList([SegList.Molecule]==n).Segment];
                
                %remove from data
                this.data.MoleculeData(n).Segment(Segs) = [];
            end
            
            %% remove empty molecules
            for n=numel(this.data.MoleculeData):-1:1
                if isempty(this.data.MoleculeData(n).Segment)
                    this.data.MoleculeData(n) = [];
                end
            end
                
            
            
            %% notify data listeners
            this.notify('DataChanged');
            
            %% notify save listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
                this.notify('SaveStatusChanged');
            end
        end
            
        %% Merge Segments
        function mergeSegments(this,SegList)
            %% create undo buffer
            this.undoDataBuffer = this.data;
            this.undoBufferAvailable = true;
            
            %% Merge
            NewSegment = this.data.MoleculeData(SegList(1).Molecule).Segment(SegList(1).Segment);
            
            NewSegment.XY = [];
            NewSegment.cspline = [];
            
            if strcmp(SegList(1).Direction,'reverse')
                NewSegment.CRnodes.X = flip(NewSegment.CRnodes.X);
                NewSegment.CRnodes.Y = flip(NewSegment.CRnodes.Y);
            end
            
            for n=2:numel(SegList)
                X = this.data.MoleculeData(SegList(n).Molecule).Segment(SegList(n).Segment).CRnodes.X; 
                Y = this.data.MoleculeData(SegList(n).Molecule).Segment(SegList(n).Segment).CRnodes.Y; 
                if strcmp(SegList(n).Direction,'reverse')
                    X = flip(X);
                    Y = flip(Y);
                end
                NewSegment.CRnodes.X = [NewSegment.CRnodes.X;X];
                NewSegment.CRnodes.Y = [NewSegment.CRnodes.Y;Y];
            end
            
            %% Set merged data
            this.data.MoleculeData(SegList(1).Molecule).Segment(SegList(1).Segment) = NewSegment;
            
            SegList(1) = [];
            %% Delete other segments
            for n=min([SegList.Molecule]):max([SegList.Molecule])
                ind = find(n==[SegList.Molecule]);
                if ~isempty(ind)
                    seg = [SegList(ind).Segment];
                    this.data.MoleculeData(n).Segment(seg) = [];
                end
            end
            %remove empty molecules
            for n=numel(this.data.MoleculeData):-1:1
                if isempty(this.data.MoleculeData(n).Segment)
                    this.data.MoleculeData(n) = [];
                end
            end
            %% notify data listeners
            this.notify('DataChanged');
            
            %% notify save listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
                this.notify('SaveStatusChanged');
            end
        end
        
        %% split segment
        function splitSegment(this,molecule,segment,NodeIndex,x,y)
            %create undo buffer
            this.undoDataBuffer = this.data;
            this.undoBufferAvailable = true;
            
            %% split
            seg = this.data.MoleculeData(molecule).Segment(segment);
            
            seg.XY = [];
            seg.cspline = [];
            
            seg2 = seg;
            
            %disp(seg2.CRnodes)
            
            seg2.CRnodes.X(1:NodeIndex,:) = [];
            seg2.CRnodes.Y(1:NodeIndex,:) = [];
            
            seg.CRnodes.X(NodeIndex+1:end,:) = [];
            seg.CRnodes.Y(NodeIndex+1:end,:) = [];
            
            seg.CRnodes.X = [seg.CRnodes.X;x];
            seg.CRnodes.Y = [seg.CRnodes.Y;y];
            
            seg2.CRnodes.X = [x;seg2.CRnodes.X];
            seg2.CRnodes.Y = [y;seg2.CRnodes.Y];
            
            %expand data
            this.data.MoleculeData(molecule).Segment = [this.data.MoleculeData(molecule).Segment(1:segment-1),...
                seg,seg2,...
                this.data.MoleculeData(molecule).Segment(segment+1:end)];
            
            %% notify data listeners
            this.notify('DataChanged');
            
            %% notify save listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
                this.notify('SaveStatusChanged');
            end
        end
        
        %% set segment node data
        function setSegmentNodes(this,mol,seg,X,Y)
            %check that there is data
            if isempty(this.data)
                return;
            end
            %create undo buffer
            this.undoDataBuffer = this.data;
            this.undoBufferAvailable = true;
            
            %% set data
            
            this.data.MoleculeData(mol).Segment(seg).CRnodes.X = X;
            this.data.MoleculeData(mol).Segment(seg).CRnodes.Y = Y;
            
            
            %% notify data listeners
            this.notify('DataChanged');
            
            %% notify save listeners
            wasOutdated = this.dataChangedSinceSave;
            this.dataChangedSinceSave = true;
            if ~wasOutdated
                %notify
                this.notify('SaveStatusChanged');
            end
            
        end
    end
    
    %% data helpers
    methods
        function L = segment_length(this,molecule,segments)
            L = NaN(size(segments));
            for n=1:numel(segments)
                X = this.data.MoleculeData(molecule).Segment(segments(n)).CRnodes.X;
                Y = this.data.MoleculeData(molecule).Segment(segments(n)).CRnodes.Y;
                [qX,qY] = crspline.CRline(X,Y,500);
                L(n) = sum(sqrt(diff(qX).^2+diff(qY).^2));
            end
            
            L = L*this.NS_data.width*1000/this.NS_data.columns; %convert to nm
            
        end
    end
    
    %% dependent variables
    methods
        function im = get.im_data_flat(this)
            im = this.data.im_data_flat;
        end
        function md = get.MoleculeData(this)
            md = this.data.MoleculeData;
        end
        function NS_data = get.NS_data(this)
            NS_data = this.data.NS_data;
        end
    end
    
    %% static functions
    methods(Static)
        [TraceData,pth,fn] = processAFMImage(filepath);
    end
end

