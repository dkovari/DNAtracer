function setSelectedCRsplines(this)

colors = this.colorGen(numel(this.MoleculeCR));%lines(numel(this.MoleculeCR));

for n=1:numel(this.MoleculeCR)
    for j=1:numel(this.MoleculeCR(n).SegCR)
        hL = this.MoleculeCR(n).SegCR(j).LineHandle;
%         hP = this.MoleculeCR(n).SegCR(j).PointsHandle;
        try
            set(hL,'LineStyle','-',...
                'color',colors(n,:),...
                'LineWidth',this.DEFAULT_LINE_WIDTH);
%             set(hP,...
%                 'MarkerFaceColor',colors(n,:),...
%                 'MarkerSize',this.DEFAULT_MARKER_SIZE);
        catch
        end
        this.MoleculeCR(n).SegCR(j).Interactive = false; %turn off interactive feature;
        
        %% set callback for non-selected lines
        try
            setappdata(hL,'MoleculeID',n);
            setappdata(hL,'SegmentID',j);
            set(hL,'ButtonDownFcn',@(h,~)this.uiSelectMolecule(h),'pickableparts','visible');
        catch
        end
        
        %% Hide points
        try
            hP = this.MoleculeCR(n).SegCR(j).PointsHandle;
            set(hP,'visible','off');
        catch
        end
        
    end
end

for n=1:numel(this.mainController.selectedMoleculeSegments)
    mol = this.mainController.selectedMoleculeSegments(n).Molecule;
    seg = this.mainController.selectedMoleculeSegments(n).Segment;
    
    for j=1:numel(seg)
        hLine = this.MoleculeCR(mol).SegCR(seg(j)).LineHandle;
        % turn off selection callback for these lines
        set(hLine,'ButtonDownFcn','','pickableparts','none');
        
        this.MoleculeCR(mol).SegCR(seg(j)).Interactive = true; %turn on interactive feature;

        hP = this.MoleculeCR(mol).SegCR(seg(j)).PointsHandle;
        set(hLine,...
            'LineStyle',this.SELECTED_LINE_STYLE,...
            'LineWidth',this.SELECTED_LINE_WIDTH,...
            'color',this.SELECTED_LINE_COLOR);
        set(hP,...
                'MarkerFaceColor',this.SELECTED_MARKER_COLOR,...
                'MarkerSize',this.SELECTED_MARKER_SIZE);

    end
end