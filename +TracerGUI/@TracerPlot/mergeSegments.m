function mergeSegments(this,SegList)
% ui driven function for merging segments using the plot

%% Clear all CR splines from plot
% for n=1:numel(this.MoleculeCR)
%     for j=1:numel(this.MoleculeCR(n).SegCR)
%         try
%         delete(this.MoleculeCR(n).SegCR(j));
%         catch
%         end
%     end     
% end
% this.MoleculeCR(1:end) = [];
for n=1:numel(this.MoleculeCR)
    for j=1:numel(this.MoleculeCR(n).SegCR)
        this.MoleculeCR(n).SegCR(j).hidePlot;
    end
end

%% Init Resulting list

MergeList = struct('Molecule',{},'Segment',{},'Direction',{});

%% Setup cursor data and keypress callback
cross_cursor = load(fullfile(fileparts(mfilename('fullpath')),'cross_cursor.mat'));
hFig = this.hFig;

state = uisuspend(hFig);

origUD = hFig.UserData;
hFig.UserData = 'wait';
origKeyCB = hFig.KeyPressFcn;
hFig.KeyPressFcn = @KeyPress;

orig_MouseMove = get(hFig,'WindowButtonMotionFcn');

%% Create Message
hTxt = uicontrol(hFig,...
    'Style','text',...
    'String','Select Endpoint of 1st segment. Press Esc to cancel.',...
    'FontSize',16,...
    'Units','points',...
    'Position',[5,5,16*63/2,24],...
    'HorizontalAlignment','center',...
    'BackgroundColor',[1,1,1]);

%% Connection Line
hConn = gobjects(numel(SegList)-1,1);
for n=1:numel(SegList)-1
    hConn(n) = line('xdata',NaN,'ydata',NaN,...
        'parent',this.hAx,...
        'color',this.SELECTED_LINE_COLOR,...
        'LineStyle','-.',...
        'pickableparts','none'); %turn off click detection on line
end

%% Plot Segments and End-points
colors = this.colorGen(numel(this.traceDataHandler.MoleculeData));
hLine = gobjects(numel(SegList),1);
hStartPoint = gobjects(numel(SegList),1);
hEndPoint = gobjects(numel(SegList),1);
for n=1:numel(SegList)
    Molecule = SegList(n).Molecule;
    Segment = SegList(n).Segment;
    X = this.traceDataHandler.MoleculeData(Molecule).Segment(Segment).CRnodes.X;
    Y = this.traceDataHandler.MoleculeData(Molecule).Segment(Segment).CRnodes.Y;
    
    SegList(n).X = [X(1),X(end)];
    SegList(n).Y = [Y(1),Y(end)];
    
    %draw segment curve
    [qX,qY] = crspline.CRline(X,Y);
    hLine(n) = line(qX,qY,'Parent',this.hAx,...
                'color',colors(Molecule,:),...
                'LineWidth',this.SELECTED_LINE_WIDTH,...
                'pickableparts','none');%turn off click detection on line
    
    %draw starting point     
    hStartPoint(n) = line(X(1),Y(1),...
        'Parent',this.hAx,...
        'Marker','o',...
        'MarkerSize',9,...
        'MarkerEdgeColor',colors(Molecule,:),...
        'MarkerFaceColor','none',...
        'pickableparts','all',...
        'ButtonDownFcn',@PointClick);
    setappdata(hStartPoint(n),'SegID',n);
    setappdata(hStartPoint(n),'PointType','start');
    
    %draw end point
    hEndPoint(n) = line(X(end),Y(end),...
        'Parent',this.hAx,...
        'Marker','d',...
        'MarkerSize',9,...
        'MarkerEdgeColor',colors(Molecule,:),...
        'MarkerFaceColor','none',...
        'pickableparts','all',...
        'ButtonDownFcn',@PointClick);
    setappdata(hEndPoint(n),'SegID',n);
    setappdata(hEndPoint(n),'PointType','end');

end


%% setup vars for first point
index = 1;
hFig.Pointer = 'custom';
hFig.PointerShapeCData = cross_cursor.cross1;
hFig.PointerShapeHotSpot = [16,16];

%% callback functions
    function PointClick(h,~)
        SegID = getappdata(h,'SegID');
        PointType = getappdata(h,'PointType');
        
        if index==1 %picking first point
            MergeList(1).Molecule = SegList(SegID).Molecule;
            MergeList(1).Segment = SegList(SegID).Segment;
            if strcmp(PointType,'start')
                MergeList(1).Direction = 'reverse';
                set(hConn(1),'Xdata',[SegList(SegID).X(1);NaN],'Ydata',[SegList(SegID).Y(1);NaN]);
            else
                MergeList(1).Direction = 'forward';
                set(hConn(1),'Xdata',[SegList(SegID).X(2);NaN],'Ydata',[SegList(SegID).Y(2);NaN]);
            end

            %set cursor to simple cross
            hFig.PointerShapeCData = cross_cursor.cross;
            
            % change message text
            hTxt.String = 'Select starting point of next segment. Esc to cancel.';
            
        else %picking joining point
            MergeList(index).Molecule = SegList(SegID).Molecule;
            MergeList(index).Segment=SegList(SegID).Segment;
            if strcmp(PointType,'start') %picked first point, forward direction
                MergeList(index).Direction = 'forward';
                x = hConn(index-1).XData;
                y = hConn(index-1).YData;   
                set(hConn(index-1),'xdata',[x(1);SegList(SegID).X(1)],'ydata',[y(1);SegList(SegID).Y(1)]);
                
                if index<numel(SegList)
                    set(hConn(index),'Xdata',[SegList(SegID).X(2);NaN],'Ydata',[SegList(SegID).Y(2);NaN]);
                end
                
            else%picked last point, reverse direction
                MergeList(index).Direction = 'reverse';
                x = hConn(index-1).XData;
                y = hConn(index-1).YData;
                set(hConn(index-1),'xdata',[x(1);SegList(SegID).X(2)],'ydata',[y(1);SegList(SegID).Y(2)]);
                
                if index<numel(SegList)
                    set(hConn(index),'Xdata',[SegList(SegID).X(1);NaN],'Ydata',[SegList(SegID).Y(1);NaN]);
                end
            end
        end
        
        %% Remove ends on clicks segment
        delete(hEndPoint(SegID));
        delete(hStartPoint(SegID));
            
        %% setup line dragging
        if index<numel(SegList)
            set(hFig,'WindowButtonMotionFcn',@(~,e)MouseMove(hConn(index),e));
        end
        %% advance index
        index = index+1;
        %% end if all selected
        if index>numel(SegList)
            hFig.UserData = 'continue';
        end
        
    end

    function KeyPress(h,e)
        %handle cancel
        if strcmp(e.Key,'escape')
            hFig.UserData = 'continue';
        end
        
        %block ctrl-z/cmd-z 
        if strcmp(e.Key,'z')
            return;
        end
        
        %handle orig key presses
        hgfeval(origKeyCB,h,e);
        
    end

    function MouseMove(hC,~)
        x= hC.XData;
        y = hC.YData;
        
        pt = get(this.hAx, 'CurrentPoint');
        x(2) = pt(1,1);
        y(2) = pt(1,2);
        
        set(hC,'xdata',x,'ydata',y);
    end


%% Wait
waitfor(hFig,'UserData','continue');

%% Cleanup graphics and other handles
delete(hTxt);
hFig.UserData = origUD;
hFig.KeyPressFcn = origKeyCB;
hFig.Pointer = 'arrow';
hFig.WindowButtonMotionFcn = orig_MouseMove;
delete(hLine);
delete(hStartPoint);
delete(hEndPoint);
delete(hConn);
try
   uirestore(state);
catch
end
%% Process
if numel(MergeList)>1
    this.mainController.selectedMoleculeChangedViaMerge([],[]);
    [OutMol,OutSeg]=this.traceDataHandler.mergeSegments(MergeList);
    this.mainController.selectedMoleculeChangedViaMerge(OutMol,OutSeg);
end

this.updateCRsplines();

%% Show cr segments
for n=1:numel(this.MoleculeCR)
    for j=1:numel(this.MoleculeCR(n).SegCR)
        this.MoleculeCR(n).SegCR(j).showPlot;
    end
end
end
