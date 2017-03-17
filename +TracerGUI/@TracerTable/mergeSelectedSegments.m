function mergeSelectedSegments(this)

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

%% Row index to molecule index

SegList(numel(Src_Act)) = struct('Molecule',[],'Segment',[]);
for n=1:numel(Src_Act)
    SegList(n).Molecule = str2num(Data{Src_Act(n)+1,1});
    SegList(n).Segment = str2num(Data{Src_Act(n)+1,2});
end

%% Call merge with main controller
this.mainController.mergeSegments(SegList);