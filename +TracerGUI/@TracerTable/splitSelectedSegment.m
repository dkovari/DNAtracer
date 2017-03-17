function splitSelectedSegment(this)

gTable = this.gTable;
Data=gTable.Data;

SelectRows =gTable.SelectedRows(1);

%% Get actual source rows
Src_Act = gTable.getActualRow(SelectRows-1);

if Src_Act==-1
    return;
end

%% Row index to molecule index
Molecule = str2num(Data{Src_Act+1,1});
Segment = str2num(Data{Src_Act+1,2});

%% Call splitSegment with main controller
this.mainController.splitSegment(Molecule,Segment);