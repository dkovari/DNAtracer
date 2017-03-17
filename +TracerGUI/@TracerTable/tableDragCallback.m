function tableDragCallback(this,SourceRow,DestinationRow)


gTable = this.gTable;
Data=gTable.Data;

SelectRows =gTable.SelectedRows;

%% Get actual source rows
for n=numel(SelectRows):-1:1
    Src_Act(n) = gTable.getActualRow(SelectRows(n)-1);
end


Src_Act(Src_Act==-1) = [];
if isempty(Src_Act)
    return;
end

%% Get Actual Rows
%Src_Act = gTable.getActualRow(SourceRow);
Dst_Act = gTable.getActualRow(DestinationRow);

%check if user dragged a molecule tree header
if DestinationRow==0
    return; %do nothing
end

%% Row index to molecule index

SegList(numel(Src_Act)) = struct('Molecule',[],'Segment',[]);
for n=1:numel(Src_Act)
    SegList(n).Molecule = str2num(Data{Src_Act(n)+1,1});
    SegList(n).Segment = str2num(Data{Src_Act(n)+1,2});
end


%% Determine destination location for start of selection
if Dst_Act == -1 %End of a section
    %determine which section
    Next_Row = gTable.getActualRow(DestinationRow+1)+1; %actual index of next row
    
    if Next_Row ==0 %end of table
        dest_mol = numel(this.traceDataHandler.data.MoleculeData);
        dest_seg = numel(this.traceDataHandler.data.MoleculeData(end).Segment)+1;
    elseif Next_Row==1 %beginnng of table
        dest_mol = 1;
        dest_seg = 1;
    else
        dest_mol = str2num(Data{Next_Row-1,1});
        dest_seg = numel(this.traceDataHandler.data.MoleculeData(dest_mol).Segment)+1;
    end
else
    dest_mol = str2num(Data{Dst_Act+1,1});
    dest_seg = str2num(Data{Dst_Act+1,2});
end

DestSeg = struct('Molecule',dest_mol,'Segment',dest_seg);


this.traceDataHandler.moveSegment(SegList,DestSeg); %this will notify data listeners of change
drawnow;

