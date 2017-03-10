function updateCRsplines(this)
%called when splines need to be updated

nMol = numel(this.traceData.MoleculeData);

if isempty(this.MoleculeCR)
    this.MoleculeCR(nMol) = struct('SegCR',[]);
end

%%
colors = lines(nMol);
%% construct crsplines
for n=1:nMol
    for j=1:numel(this.traceData.MoleculeData(n).Segment)
        X = this.traceData.MoleculeData(n).Segment(j).CRnodes.X;
        Y = this.traceData.MoleculeData(n).Segment(j).CRnodes.Y;
        
        if numel(this.MoleculeCR(n).SegCR) < j
            this.MoleculeCR(n).SegCR(j) = crspline(X,Y);            
        else
            try
                this.MoleculeCR(n).SegCR(j).X = X;
                this.MoleculeCR(n).SegCR(j).Y = Y;
            catch
                try
                    delete(this.MoleculeCR(n).SegCR(j));
                catch
                end
                this.MoleculeCR(n).SegCR(j) = crspline(X,Y);
            end
        end
        
        if ~this.MoleculeCR(n).plotValid
            plot(this.MoleculeCR(n).SegCR(j),'Parent',this.hAx,'interactive','true','LineProperties',{'color',colors(n,:)});
        end
        
        this.MoleculeCR(n).SegCR(j) = @(~,~) this.uiPlotEditCallback(n,j);
    end
end

%% set the linestyle for selected molecules
this.setSelectedCRsplines();