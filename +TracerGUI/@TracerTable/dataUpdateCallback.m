function dataUpdateCallback(this)
%update table to reflect traceData
%associated with DataChanged event

this.gTable.Data = this.makeTableCellData();