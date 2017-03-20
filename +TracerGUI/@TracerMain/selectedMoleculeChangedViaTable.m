function selectedMoleculeChangedViaTable(this,Molecules,Segments)
% traceMain function for changing the selected molecules
%   Specify Molecule and Segment as two vectors
%       OR
%   Specify using a SegList struct
%       selectedMoleculeChangedViaTable(struct('Molecule',{...},'Segment',{...}))    

if nargin<3 && isstruct(Molecules)
    this.selectedMoleculeSegments = Molecules;
else
    Molecules = num2cell(Molecules);
    this.selectedMoleculeSegments = struct('Molecule',{},'Segment',{});

    [this.selectedMoleculeSegments(1:numel(Molecules)).Molecule] = deal(Molecules{:});

    Segments = num2cell(Segments);

    [this.selectedMoleculeSegments(1:numel(Segments)).Segment] = deal(Segments{:});
end


%% select molecule on image
try
    this.tracePlot.setSelectedCRsplines();
catch
end


