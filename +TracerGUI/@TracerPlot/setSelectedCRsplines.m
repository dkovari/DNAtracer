function setSelectedCRsplines(this)

for n=1:numel(this.mainController.selectedMoleculeSegments)
    mol = this.mainController.selectedMoleculeSegments(n).Molecule;
    seg = this.mainController.selectedMoleculeSegments(n).Segment;
    
    try
    hLine = this.MoleculeCR(mol).SegCR(seg).LineHandle;
    set(hLine,'LineStyle','-.');
    catch
    end
end