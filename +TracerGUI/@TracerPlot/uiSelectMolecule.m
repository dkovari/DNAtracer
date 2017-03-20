function uiSelectMolecule(this,hObj)

MoleculeID = getappdata(hObj,'MoleculeID');
SegmentID = getappdata(hObj,'SegmentID');


%% tell mainController to change selection
this.mainController.selectMoleculeChangedViaPlot(MoleculeID,SegmentID);

