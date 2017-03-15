function selecedMoleculeChangedViaTable(this,Molecules,Segments)

Molecules = num2cell(Molecules);
this.selectedMoleculeSegments = struct('Molecule',{},'Segment',{});

[this.selectedMoleculeSegments(1:numel(Molecules)).Molecules] = deal(Molecules{:});

Segments = num2cell(Segments);

[this.selectedMoleculeSegments(1:numel(Segments)).Segments] = deal(Segments{:});


%% select molecule on image

try
    this.tracePlot.setSelectedCRsplines();
end


