function splitSegment(this,Molecule,Segment)

%% Clear all CR splines from plot

for n=1:numel(this.MoleculeCR)
    for j=1:numel(this.MoleculeCR(n).SegCR)
        try
        delete(this.MoleculeCR(n).SegCR(j));
        catch
        end
    end     
end
this.MoleculeCR(1:end) = []; 


%% Draw CR Spline for current segment
X = this.traceDataHandler.MoleculeData(Molecule).Segment(Segment).CRnodes.X;
Y = this.traceDataHandler.MoleculeData(Molecule).Segment(Segment).CRnodes.Y;

% hLine = plot(CR,'Parent',this.hAx,...
%                 'interactive',false,...
%                 'LineProperties',{'color',this.SELECTED_LINE_COLOR,...
%                                     'LineWidth',this.DEFAULT_LINE_WIDTH});
% hLine.HitTest = 'off';
%% make hidden hit-testing segments
hSeg = gobjects(numel(X)-1,1);
for n = 1:numel(X)-1
    [qX,qY] = crspline.CRseg(X,Y,n);
    hSeg(n) = line(qX,qY,...
        'parent',this.hAx,...
        'pickableparts','all',...
        'ButtonDownFcn',@LineClick,...
        'color',this.SELECTED_LINE_COLOR,...
        'LineWidth',this.SELECTED_LINE_WIDTH);
    setappdata(hSeg(n),'SegID',n);
end
                                
%%
BreakPt_X = NaN;
BreakPt_Y = NaN;
NodeIndex = NaN;

STATUS = 'hold';

orig_UD = this.hAx.UserData;
                                
%% Set the cursor

cursor = double(diag(ones(30,1),-2)|diag(ones(30,1),2)|fliplr(diag(ones(30,1),-2)|diag(ones(30,1),2)));
cursor(eye(32,32)|diag(ones(31,1),-1)|diag(ones(31,1),1)|fliplr(eye(32,32)|diag(ones(31,1),-1)|diag(ones(31,1),1))) = 2;
cursor(16:17,16:17) = 0;%figure();imagesc(cursor);axis image
cursor(cursor==0) = NaN;

hFig = this.hAx.Parent;
hFig.PointerShapeCData = cursor;
hFig.PointerShapeHotSpot = [16,16];
hFig.Pointer = 'custom';

%% Create Message Label
hTxt = uicontrol(hFig,...
    'Style','text',...
    'String','Choose location to break highlighted segment. Press Esc to cancel.',...
    'FontSize',16,...
    'Units','points',...
    'Position',[5,5,16*63/2,16],...
    'HorizontalAlignment','center',...
    'BackgroundColor',[1,1,1]);

%% Change callbacks and userdata
this.hAx.UserData = 'wait';
orig_KeyCB = hFig.KeyPressFcn;

hFig.KeyPressFcn = @KeyPress;


%% Callbacks
    function LineClick(h,e)
        if e.Button~=1
            return;
        end
        
        NodeIndex = getappdata(h,'SegID');
        BreakPt_X = e.IntersectionPoint(1);
        BreakPt_Y = e.IntersectionPoint(2);
        STATUS = 'clicked';
        this.hAx.UserData = 'continue';
    end

    function KeyPress(~,e)
        if strcmp(e.Key,'escape')
            STATUS = 'canceled';
            this.hAx.UserData = 'continue';
        end
    end

%% wait 
waitfor(this.hAx,'UserData','continue');

this.hAx.UserData = orig_UD;
try
delete(hSeg)
delete(hTxt);
catch
end

hFig.KeyPressFcn = orig_KeyCB;

%% Clean Up
hFig.Pointer = 'arrow';
%% process
if strcmp(STATUS,'clicked')
    %'in click proc'
    this.traceDataHandler.splitSegment(Molecule,Segment,NodeIndex,BreakPt_X,BreakPt_Y); %changes data, throws datachange event
else
    %'else'
    this.updateCRsplines();
end


end


