function [data,headers] = makeTableCellData(this)

headers = {'Molecule','Segment','Length [nm]','Cumulative Length [nm]'};

nRows = 0;
for n=1:numel(this.traceDataHandler.MoleculeData)
    nRows=nRows+numel(this.traceDataHandler.MoleculeData(n).Segment);
end

data = cell(nRows,4);
row = 0;
for n=1:numel(this.traceDataHandler.MoleculeData)
    CumLength = 0;
    for j=1:numel(this.traceDataHandler.MoleculeData(n).Segment)
        row=row+1;
        
        data{row,1} = num2str(n);
        data{row,2} = num2str(j);
        data{row,3} = this.traceDataHandler.segment_length(n,j);
        CumLength = CumLength + data{row,3};
        data{row,4} = CumLength;
    end
end

