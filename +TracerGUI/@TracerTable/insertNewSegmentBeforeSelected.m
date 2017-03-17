function insertNewSegmentBeforeSelected(this)

gTable = this.gTable;
Data=gTable.Data;

SelectedRow =gTable.SelectedRows(1);

%% Get actual source rows
Src_Act = gTable.getActualRow(SelectedRow-1);

if Src_Act==-1
    return;
end

%% Row index to molecule index
Molecule = str2num(Data{Src_Act+1,1});
Segment = str2num(Data{Src_Act+1,2});

%% Call createNewSegment with main controller
this.mainController.createNewSegment(Molecule,Segment);