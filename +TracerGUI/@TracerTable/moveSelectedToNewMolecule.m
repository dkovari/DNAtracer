function moveSelectedToNewMolecule(this)
% traceTable callback for moving selected molecules to new molecule

SelectRows = this.gTable.SelectedRows;

if isempty(SelectRows)
    return;
end

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

%% set data
newSegList = this.traceDataHandler.newMoleculeFromSegments(SegList);

%% Update selection
this.mainController.selectedMoleculeChangedViaTable(newSegList);

% Update table
this.updatedSelectedRows();