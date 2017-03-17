function createNewSegment(this,Molecule,Segment)
% Main Controller function for creating new segment

SegData=this.tracePlot.UIcreateNewSegment();

SegList = struct('Molecule',Molecule,'Segment',Segment);

this.traceDataHandler.insertSegment(SegList,SegData);
