function selecedMoleculeChangedViaTable(this,Molecules,Segments)

Molecules = num2cell(Molecules);
this.selectedMoleculeSegments = struct('Molecule',{},'Segment',{});

[this.selectedMoleculeSegments(1:numel(Molecules)).Molecule] = deal(Molecules{:});

Segments = num2cell(Segments);

[this.selectedMoleculeSegments(1:numel(Segments)).Segment] = deal(Segments{:});


%% select molecule on image

try
    this.tracePlot.setSelectedCRsplines();
catch
end


