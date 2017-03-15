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
CR = crspline(X,Y);

hLine = plot(CR,'Parent',this.hAx,...
                'interactive',true,...
                'LineProperties',{'color',this.SELECTED_LINE_COLOR,...
                                    'LineWidth',this.DEFAULT_LINE_WIDTH});
hLine.HitTest = 'off';
%% make hidden hit-testing segments
hSeg = gobjects(numel(this.pX)-1,1);
for n = 1:numel(X)-1
    [qX,qY] = crspline.CRseg(X,X,n);
    hSeg(n) = line(qX,qY,'visible','off','pickableparts','all','ButtonDownFcn',@LineClick);
    setappdata(hSeg(n),'SegID',n);
end
                                
%%
BreakPt_X = NaN;
BreakPt_Y = NaN;
NodeIndex = NaN;
                                
%% Set the cursor

cursor = double(diag(ones(30,1),-2)|diag(ones(30,1),2)|fliplr(diag(ones(30,1),-2)|diag(ones(30,1),2)));
cursor(eye(32,32)|diag(ones(31,1),-1)|diag(ones(31,1),1)|fliplr(eye(32,32)|diag(ones(31,1),-1)|diag(ones(31,1),1))) = 2;
cursor(16:17,16:17) = 0;%figure();imagesc(cursor);axis image
cursor(cursor==0) = NaN;

hFig = this.hAx.Parent;
hFig.PointerShapeCData = cursor;
hFig.PointerShapeHotSpot = [16,16];
hFig.Pointer = 'custom';

%% Change line callback
hLine.UserData = 'wait';


%% Callbacks
    function LineClick(h,e)
        if e.Button~=1
            return;
        end
        
        NodeIndex = getappdata(h,'SegID');
        BreakPt_X = e.IntersectionPoint(1);
        BreakPt_Y = e.IntersectionPoint(1);
        hLine.UserData = 'clicked';
    end

    function KeyPress(h,e)
        hLine.UserData = 'canceled';
    end
%% wait 
waitfor(hLine,'UserData');
UD = hLine.UserData;
try
delete(hLine);
delete(hSeg)
catch
end

%% Clean Up
hFig.Pointer = 'arrow';
%% process
if strcmp(UD,'clicked')
    this.traceDataHandler.splitSegment(this,Molecule,Segment,NodeIndex,BreakPt_X,BreakPt_Y); %changes data, throws datachange event
else
    this.updateCRsplines();
end


end


