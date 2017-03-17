function createNewMolecule(this)
%table callback for creating new molecule

%% Call createNewSegment with main controller
mol = numel(this.traceDataHandler.MoleculeData)+1;
this.mainController.createNewSegment(mol,1);