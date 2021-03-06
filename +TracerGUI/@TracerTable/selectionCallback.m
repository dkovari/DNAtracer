function selectionCallback(this,gTable,evt)

sel_row = evt.Indices;
Act_row = NaN(size(sel_row));
for n=1:numel(sel_row)
    Act_row(n) = gTable.getActualRow(sel_row(n)-1);
end
bad = find(Act_row==-1);
sel_row(bad) = [];
Act_row(bad) = [];
Act_row = Act_row+1;

Molecules = NaN(numel(Act_row),1);
Segments = NaN(numel(Act_row),1);

data = gTable.Data;

for n=1:numel(Act_row)
    Molecules(n) = str2num(data{Act_row(n),1});
    Segments(n) = str2num(data{Act_row(n),2});
end

%% set selectedMolecule

this.mainController.selectedMoleculeChangedViaTable(Molecules,Segments);


%% Set selected rows in table
gTable.SelectedRows = sel_row;


%% if needed hide single/mulit segment operations in context menu
try
if numel(sel_row)==0
    this.hMenu_Split.Visible = 'off';
    this.hMenu_Merge.Visible = 'off';
    this.hMenu_MoveToNew = 'off';
    this.hMenu_Delete = 'off';
    this.hMenu_InsBefore = 'off';
    this.hMenu_InsAfter = 'off';
elseif numel(sel_row)==1
    this.hMenu_Split.Visible = 'on';
    this.hMenu_Merge.Visible = 'off';
    this.hMenu_MoveToNew = 'on';
    this.hMenu_Delete = 'on';
    this.hMenu_InsBefore = 'on';
    this.hMenu_InsAfter = 'on';
else
    this.hMenu_Split.Visible = 'off';
    this.hMenu_Merge.Visible = 'on';
    this.hMenu_MoveToNew = 'on';
    this.hMenu_Delete = 'on';
    this.hMenu_InsBefore = 'on';
    this.hMenu_InsAfter = 'on';
end

catch
end