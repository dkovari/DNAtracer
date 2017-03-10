function tableDragCallback(this,SourceRow,DestinationRow)


gTable = this.gTable;
Data=gTable.Data;

%% Get Actual Rows
Src_Act = gTable.getActualRow(SourceRow);
Dst_Act = gTable.getActualRow(DestinationRow);

%check if user dragged a molecule tree header
if Src_Act==-1 || DestinationRow==0
    return; %do nothing
end

src_mol = str2num(Data{Src_Act,1});
src_seg = str2num(Data{Src_Act,2});

if Dst_Act == -1 %End of a section
    %determine which section
    Next_Row = gTable.getActualRow(DestinationRow+1)+1; %actual index of next row
    
    if Next_Row ==0 %end of table
        dest_mol = numel(this.traceDataHandler.data.MoleculeData);
        dest_seg = numel(this.traceDataHandler.data.MoleculeData(end).Segment)+1;
    elseif Next_Row==1 %beginnng of table
        dest_mol = 1;
        dest_seg = 1;
    else
        dest_mol = str2num(Data{Next_Row-1,1});
        dest_seg = numel(this.traceDataHandler.data.MoleculeData(end).Segment)+1;
    end
end

if src_seg==dest_seg && src_mol==dest_mol %didn't acutally move a row, do nothing
    return;
end

this.traceDataHandler.moveSegmentMolecule(src_mol,src_seg,dest_mol,dest_seg); %this will notify data listeners of change

