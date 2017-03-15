function deleteSelected(this)

SelectRows = this.gTable.SelectedRows;

%% Get actual source rows
for n=numel(SelectRows):-1:1
    Src_Act(n) = this.gTable.getActualRow(SelectRows(n)-1);
end
Data = this.gTable.Data;
SegList(numel(Src_Act)) = struct('Molecule',[],'Segment',[]);
for n=1:numel(Src_Act)
    SegList(n).Molecule = str2num(Data{Src_Act(n)+1,1});
    SegList(n).Segment = str2num(Data{Src_Act(n)+1,2});
end

%% Delete data, this calls the datachange event
this.traceDataHandler.removeSegment(SegList);
