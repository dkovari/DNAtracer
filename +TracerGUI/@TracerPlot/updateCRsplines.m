function updateCRsplines(this)
%called when splines need to be updated

nMol = numel(this.traceDataHandler.MoleculeData);

if isempty(this.MoleculeCR)
    this.MoleculeCR(nMol) = struct('SegCR',crspline());
end

%%
colors = lines(nMol);
%% construct crsplines
for n=1:nMol
    for j=numel(this.traceDataHandler.MoleculeData(n).Segment):-1:1
        X = this.traceDataHandler.MoleculeData(n).Segment(j).CRnodes.X;
        Y = this.traceDataHandler.MoleculeData(n).Segment(j).CRnodes.Y;
        
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
        
        if ~this.MoleculeCR(n).SegCR(j).plotValid()
            plot(this.MoleculeCR(n).SegCR(j),'Parent',this.hAx,...
                'interactive',true,...
                'LineProperties',{'color',colors(n,:),'LineWidth',1.5},...
                'PointProperties',{'MarkerSize',6,'Marker','s','LineStyle','none','MarkerFaceColor',colors(n,:),'MarkerEdgeColor','none'});
        end
        
        this.MoleculeCR(n).SegCR(j).UIeditCallback = @(~,~) this.uiPlotEditCallback(n,j);
    end
end

%% set the linestyle for selected molecules
this.setSelectedCRsplines();