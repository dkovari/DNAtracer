function selectedMoleculeChangedViaMerge(this,Molecule,Segment)

%% set the selected molecule
if isempty(Molecule)
    this.selectedMoleculeSegments = struct('Molecule',{},'Segment',{});
else
this.selectedMoleculeSegments = struct('Molecule',Molecule,'Segment',Segment);
end

%% Update the table
this.traceTable.updatedSelectedRows();
