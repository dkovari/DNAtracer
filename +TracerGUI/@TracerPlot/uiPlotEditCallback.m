function uiPlotEditCallback(this,mol,seg)

X = this.MoleculeCR(mol).SegCR(seg).X;
Y = this.MoleculeCR(mol).SegCR(seg).Y;

%% set data in dataHandler
%This will throw a dataChange Event

try
    this.traceDataHandler.setSegmentNodes(mol,seg,X,Y);
catch
end