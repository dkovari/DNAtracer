function selecedMoleculeChangedViaPlot(this,Molecule,Segment)

%% set the selected molecule
this.selectedMoleculeSegments = struct('Molecule',Molecule,'Segment',Segment);

%% Update the table


%% update the plot
this.tracePlot.setSelectedCRsplines();

