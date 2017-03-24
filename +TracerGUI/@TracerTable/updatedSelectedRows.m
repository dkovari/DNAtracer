function updatedSelectedRows(this)
%method for updating selected table rows

%% convert selected segment list to row index
rows = zeros(numel(this.mainController.selectedMoleculeSegments),1);

if isempty(rows)
    this.gTable.setSelectedDataRows([]);
    return;
end

data=this.gTable.Data;
mols = data(:,1);
segs = data(:,2);

molecules = zeros(size(mols));
segments = zeros(size(segs));
for n=1:numel(mols)
    molecules(n) = str2num(mols{n});
    segments(n) = str2num(segs{n});
end

for n=1:numel(this.mainController.selectedMoleculeSegments)
    Seg = this.mainController.selectedMoleculeSegments(n);
    rows(n) = find( Seg.Molecule==molecules & Seg.Segment==segments);
end

%% select rows
this.gTable.setSelectedDataRows(rows);
