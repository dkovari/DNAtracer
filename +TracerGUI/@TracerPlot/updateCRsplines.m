function updateCRsplines(this)
%called when splines need to be updated

nMol = numel(this.traceDataHandler.MoleculeData);

if isempty(this.MoleculeCR)
    this.MoleculeCR(nMol) = struct('SegCR',crspline());
end

%% Delete extra molecules
for n=nMol+1:numel(this.MoleculeCR)
    for j=1:numel(this.MoleculeCR(n).SegCR)
        try
        delete(this.MoleculeCR(n).SegCR(j));
        catch
        end
    end     
end
this.MoleculeCR(nMol+1:end) = [];

%% Create extra MoleculeCR if we've added new molecules
if nMol>numel(this.MoleculeCR)
    this.MoleculeCR(nMol) = struct('SegCR',crspline());
end

%%
colors = this.colorGen(nMol);%lines(nMol);
%% construct crsplines
for n=1:nMol
    
    N_SEG = numel(this.traceDataHandler.MoleculeData(n).Segment);
    try %delete any extra segments
        delete(this.MoleculeCR(n).SegCR(N_SEG+1:end));
        this.MoleculeCR(n).SegCR(N_SEG+1:end)=[];
    catch
    end
    
    for j=N_SEG:-1:1
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
                'LineProperties',{'color',colors(n,:),'LineWidth',this.DEFAULT_LINE_WIDTH},...
                'PointProperties',{'MarkerSize',this.DEFAULT_MARKER_SIZE,...
                                    'Marker','s',...
                                    'LineStyle','none',...
                                    'MarkerFaceColor',colors(n,:),...
                                    'MarkerEdgeColor','none'});
        end
        this.MoleculeCR(n).SegCR(j).UIeditCallback = @(~,~) this.uiPlotEditCallback(n,j);

    end
end

%% set the linestyle for selected molecules
this.setSelectedCRsplines();