function selectionCallback(this,gTable,evt)

sel_row = evt.Indices;
Act_row = NaN(size(sel_row));
for n=1:numel(sel_row)
    Act_row(n) = gTable.getActualRow(sel_row(n)-1);
end

Act_row(Act_row==-1) = [];
Act_row = Act_row+1;

Molecules = NaN(numel(Act_row),1);
Segments = NaN(numel(Act_row),1);

data = gTable.Data;

for n=1:numel(Act_row)
    Molecules(n) = str2num(data{Act_row(n),1});
    Segments(n) = str2num(data{Act_row(n),2});
end

%% set selectedMolecule

this.mainController.selecedMoleculeChangedViaTable(Molecules,Segments);

