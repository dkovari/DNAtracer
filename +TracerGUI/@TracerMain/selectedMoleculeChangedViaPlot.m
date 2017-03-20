function selectedMoleculeChangedViaPlot(this,Molecule,Segment)

%% set the selected molecule
this.selectedMoleculeSegments = struct('Molecule',Molecule,'Segment',Segment);

%% Update the table
this.traceTable.updatedSelectedRows();

%% update the plot
this.tracePlot.setSelectedCRsplines();

