classdef crspline < matlab.mixin.SetGet
%CRSPLINE Create a 2D Catmull-Rom Spline
% Catumll-Rom Splines are cubic splines defined only by knot locations.
% 
% Usage:
%   cr_obj = crspline(X,Y)
%       X and Y are vecotors specifying the knot locations along the
%       parametric curve
%
% Overloaded Functions:
%   plot(crspline, ...): Plots the spline
%       plot(cr_obj) plots the entire curve
%
%       plot(cr_obj,S) plots the curve evaluated at the
%           parametric points specified in S
%           S is valid on the range [0,numel(X)-1]
%           Each integer n corresponds with the curve being evaluated
%           at the (n+1)-th segment. E.g. values from 0->1 are computed
%           using the first segment, 1->2 using the second, etc.
%
%       plot(...,'LineProperties',{Name,Value},'PointProperties',{Name,Value})
%               allows you to specifiy how the line should be plotted
%               The style used to plot the knots is specified by
%               'PointProperties'.
%
%       plot(...,'Interactive',true) generates an interactive curve
%       allowing the user to add, remove, and move knots
%
%
% Firing Callbacks from edits
%   The X and Y values are observable, so you can create event listeners to
%   monitor set-changes to those parameters
%
%   Alternatively, you can set the callback:
%       hCrObj.UIeditCallback = ...[YOUR_FUNCTION]...
%   which will call [YOUR_FUNCTION] using the standard matlab callback
%   conventions
%
%% Copyright 2017, Daniel T. Kovari, Emory University
% All rights reserved

%% Change Log
%   2017-02-02 DTK
%       Initial creation
%   2017-03-10 DTK
%       Added listeners for changes to X and Y data
%       added Callback for ui-edit events

%% Class Def 
    properties (SetObservable = true)
        X; %xpoints
        Y; %ypoints
        Tension=0.5;
    end
    
    properties (Access=private)
        pX;
        pY;
    end
    
    properties
        UIeditCallback;
    end
    
    properties (Access=private)
        hAx;
        hLine
        hPts
        hSeg
        MOVE_PT;
        CLICK_ON=false;
        
        pInteractivePlot;
        
        orig_MouseMove;
        orig_MouseUp;
    end
    
    properties (Dependent=true)
        Interactive
    end
    
    %x
    properties(Access=private,Dependent=true)
        pltX;
        pltY;
    end
    methods
        function X = get.pltX(this)
            if numel(this.pX)<numel(this.pY)
                X = [this.pX;NaN(numel(this.pY)-numel(this.pX),1)];
            else
                X=this.pX;
            end
        end
        function Y = get.pltY(this)
            if numel(this.pY)<numel(this.pX)
                Y = [this.pY;NaN(numel(this.pX)-numel(this.pY),1)];
            else
                Y=this.pY;
            end
        end
    end
    
    methods %creator destructor
        function this = crspline(X,Y,varargin)
            
            if nargin<2
                X=[];
                Y = [];
            end

            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Tension',0.5,@(x) isnumeric(x)&&isscalar(x));
            parse(p,varargin{:});
            this.Tension = p.Results.Tension;
            
            if any(size(X)~=size(Y))
                error('X and Y must be same size');
            end
            this.pX = reshape(X,[],1);
            this.pY = reshape(Y,[],1);
            
            this.X = this.pX;
            this.Y = this.pY;
        end
        function delete(this)
            try
                delete(this.hLine);
            catch
            end
            try
                delete(this.hPts);
            catch
            end
            try 
                delete(this.hSeg);
            catch
            end
        end
    end
    
    methods
        function L = curve_length(this)
            [qX,qY] = crspline.CRline(this.pX,this.pY,500,this.Tension);
            L = sum(sqrt(diff(qX).^2+diff(qY).^2));
        end
    end
    
    %% Plot
    methods %overloads
        
        function [hLine,hPts] = plot(this,varargin)
            % Overload for standard plot()
            % accepts crspline object as first input or using obj.method
            % notation
            
            %% validate input
            p = inputParser;
            p.CaseSensitive = false;
            p.KeepUnmatched = true;
            
            addParameter(p,'Parent',[],@(x) isempty(x)||ishghandle(x)&&ismember(get(x,'type'),{'figure','axes'}));
            addParameter(p,'Interactive',false,@(x) isscalar(x));
            addParameter(p,'LineProperties',{});
            addParameter(p,'PointProperties',{});
            
            %if first arg is numeric, use that at the parametric points
            S_data = [];
            if isnumeric(varargin{1})
                S_data = varargin{1};
                varargin(1) = [];
            end
            
            parse(p,varargin{:});
            
            if isempty(p.Results.Parent)
                this.hAx = gca;
            else
                switch(get(p.Results.Parent,'type'))
                    case 'figure'
                        this.hAx = get(p.Results.Parent,'currentaxes');
                    case 'axes'
                        this.hAx = p.Results.Parent;
                end
            end
            
            
            if ~isempty(S_data)%specified parametric points
                qX = NaN(size(S_data));
                qY = NaN(size(S_data));

                for n=1:numel(S_data) %evaluate at each point
                    if S_data(n)<0||S_data(n)>numel(this.pX)-1
                        continue;
                    end

                    if ~mod(S_data(n),1)
                        qX(n) = this.pX(S+data(n)+1);
                        qY(n) = this.pY(S+data(n)+1);
                        continue;
                    end

                    seg = ceil(S_data(n));
                    s = S_data(n)-seg+1;

                    X = this.pX;
                    Y = this.pY;

                    if seg<2
                        X = [X(1);X];
                        Y = [Y(1);Y];
                    else
                        seg=seg-1;
                    end
                    if seg>numel(X)-3
                        X = [X;X(end)];
                        Y = [Y;Y(end)];
                    end

                    [qX(n),qY(n)] = crspline.CR(X(seg:seg+3),Y(seg:seg+3),s,this.Tension);
                end
            else %user did not specify s_Data just plot all data
                [qX,qY] = crspline.CRline(this.pltX,this.pltY,100,this.Tension);
            end
            
            hPts = gobjects(0);
            %hLine = gobjects(0);
            
            %plot the line
            if isempty(p.Results.LineProperties)
                hLine = plot(qX,qY,'parent',this.hAx,p.Unmatched);
            else
                if iscell(p.Results.LineProperties)
                    hLine = plot(qX,qY,'parent',this.hAx,p.Results.LineProperties{:});
                elseif isstruct(p.Results.LineProperties)
                    hLine = plot(qX,qY,'parent',this.hAx,p.Results.LineProperties);
                else
                    hLine = plot(qX,qY,'parent',this.hAx,'LineStyle','-');
                end
            end
            %plot the points if user specified style, or interactive
            if ~isempty(p.Results.PointProperties)||p.Results.Interactive
                if iscell(p.Results.PointProperties)&&~isempty(p.Results.PointProperties)
                    hPts = line('xdata',this.pltX,'ydata',this.pltY,'parent',this.hAx,p.Results.PointProperties{:});
                elseif isstruct(p.Results.PointProperties)
                    hPts = line('xdata',this.pltX,'ydata',this.pltY,'parent',this.hAx,p.Results.PointProperties);
                else
                    hPts = line('xdata',this.pltX,'ydata',this.pltY,...
                        'parent',this.hAx,...
                        'LineStyle','none',...
                        'marker','s',...
                        'markeredgecolor',get(hLine,'color'),...
                        'markerfacecolor',get(hLine,'Color'),...
                        'markersize',8);
                end
            end
            
            if p.Results.Interactive
                % Create hidden segment lines, for adding points to the
                % curve
                this.hSeg = gobjects(numel(this.pX)-1,1);
                for n = 1:numel(this.pX)-1
                    [qX,qY] = crspline.CRseg(this.pX,this.pY,n,this.Tension);
                    this.hSeg(n) = line(qX,qY,'visible','off','pickableparts','all','ButtonDownFcn',@(h,e) this.AddPt(h,e));
                    setappdata(this.hSeg(n),'SegID',n);
                end
                
                %callbacks for moving points
                set(hPts,'ButtonDownFcn',@(h,e) this.MouseClick(h,e));
                
                
                %delete points menu
                hMenu = uicontextmenu(this.hAx.Parent);
                hPts.UIContextMenu = hMenu;
                uimenu(hMenu,'label','Delete Point','callback',@(h,e) this.DeletePt(h,e));
                
                %move points to top
                try
                    %uistack(hPts,'top');
                    restack(this.hAx,hPts,this.hSeg);
                catch
                end

            end

            %% Set Object properties
            this.pInteractivePlot = p.Results.Interactive;
            this.hLine = hLine;
            this.hPts = hPts;
            
        end
        
    end
    
    %% plot interactions
    methods
        function hidePlot(this)
            if ~this.plotValid
                return;
            end
            
            try
                set(this.hLine,'visible','off');
            catch
            end
            try
                set(this.hPts,'visible','off');
            catch
            end
            try
                set(this.hSeg,'pickableparts','none');
            catch
            end
                
                
        end
        function showPlot(this)
            if ~this.plotValid
                return;
            end
            try
                set(this.hLine,'visible','on');
            catch
            end
            try
                set(this.hPts,'visible','on');
            catch
            end
            try
                set(this.hSeg,'pickableparts','all');
            catch
            end
        end
    end
    
    %% get/set methods
    methods
        function set.X(this,X)
            X = reshape(X,[],1);
            this.X = X;
            if numel(X)~=numel(this.pX)||any(X~=this.pX)
                this.pX = X;
                this.update_draw();
            end
        end
        function set.Y(this,Y)
            Y = reshape(Y,[],1);
            this.Y = Y;
            if numel(Y)~=numel(this.pY)||any(Y~=this.pY)
                this.pY = Y;
                this.update_draw();
            end
        end
        function set.Tension(this,T)
            if ~(isscalar(T)&&isnumeric(T))
                return;
            end
            this.Tension = T;
            this.update_draw();
        end
        function set.UIeditCallback(this,fcn)
            assert( isa(fcn,'function_handle')||...
                ischar(fcn)||...
                (iscell(fcn)&&...
                    (isa(fcn{1},'function_handle')||ischar(fcn{1}))),...
                    'invalid callback function');
            this.UIeditCallback = fcn;
        end
        function b = plotValid(this)
            b=~isempty(this.hLine)&&ishghandle(this.hLine);
        end
        function hl = LineHandle(this)
            hl = this.hLine;
        end
        function hP = PointsHandle(this)
            hP = this.hPts;
        end
        
        function set.Interactive(this,bool)
            if ~this.plotValid
                return;
            end
            
            X = this.pltX;
            Y = this.pltY;
            if bool && ~this.pInteractivePlot %turn interactive on
                %create hidden segments if needed
                if numel(this.hSeg)<numel(X)-1
                    this.hPts(numel(this.hPts)+1:(numel(X)-1)) = gobjects((numel(X)-1)-numel(this.hPts));
                end
                for n=numel(this.hSeg):-1:1
                    if ~ishghandle(this.hSeg(n))
                        [qX,qY] = crspline.CRseg(X,Y,n,this.Tension);
                        this.hSeg(n) = line(qX,qY,'visible','off','pickableparts','all','ButtonDownFcn',@(h,e) this.AddPt(h,e));
                        setappdata(this.hSeg(n),'SegID',n);
                    else
                        set(this.hSeg(n),'visible','pickableparts','all');
                    end
                end
                
                %create hPts if needed
                if isempty(this.hPts)||~ishghandle(this.hPts)
                    this.hPts = line('xdata',this.pltX,'ydata',this.pltY,...
                        'parent',this.hAx,...
                        'LineStyle','none',...
                        'marker','s',...
                        'markeredgecolor',get(this.hLine,'color'),...
                        'markerfacecolor',get(this.hLine,'Color'),...
                        'markersize',8,...
                        'ButtonDownFcn',@(h,e) this.MouseClick(h,e));
                else
                    set(this.hPts,'visible','on');
                end
                restack(this.hAx,this.hPts,this.hSeg);
                this.pInteractivePlot = true;
            elseif ~bool && this.pInteractivePlot %turn off
                try
                    set(this.hPts,'visible','off');
                catch
                end
                try
                    set(this.hSeg,'pickableparts','none');
                catch
                end
                this.pInteractivePlot = false;
            end
            
        end
        function bool = get.Interactive(this)
            bool=this.pInteractivePlot;
        end
    end
    
    %% internal methods
    methods(Access=private)
        function update_draw(this)
            
            if isempty(this.hLine)||~ishghandle(this.hLine)
                return;
            end

            %update line
            [qx,qy] = crspline.CRline(this.pltX,this.pltY,100,this.Tension);

            try
                set(this.hLine,'xdata',qx,'ydata',qy');
            catch
            end
            %update points
            if ~isempty(this.hPts) && ishghandle(this.hPts)
                try
                    set(this.hPts,'xdata',this.pltX,'ydata',this.pltY);
                catch
                end
            end
            if this.pInteractivePlot
                %update hidden segments
                if isempty(this.hSeg)
                    this.hSeg = gobjects(numel(this.pltX)-1,1);
                end
                for n=numel(this.pltX)-1:-1:1
                    [qX,qY] = crspline.CRseg(this.pX,this.pY,n,this.Tension);
                    if n>numel(this.hSeg) || ~ishghandle(this.hSeg(n))%new segment
                        this.hSeg(n) = line(qX,qY,'parent',this.hAx,'visible','off','pickableparts','all','ButtonDownFcn',@(h,e) this.AddPt(h,e));
                        setappdata(this.hSeg(n),'SegID',n);
                    else %just reset the data
                        set(this.hSeg(n),'XData',qX,'YData',qY);
                    end
                        
                end

                %put points back on top
                %uistack(this.hPts,'top');
                restack(this.hAx,this.hPts,this.hSeg);
            end
        end
    end

    methods %callbacks
        function MouseClick(this,~,e)
            [~,this.MOVE_PT] = min( (this.pX-e.IntersectionPoint(1)).^2 + (this.pY-e.IntersectionPoint(2)).^2);
            if e.Button==1
                this.CLICK_ON = true;
                hFig = get(this.hAx,'parent');
                this.orig_MouseMove = get(hFig,'WindowButtonMotionFcn');
                this.orig_MouseUp = get(hFig,'WindowButtonUpFcn');
                set(hFig,'WindowButtonUpFcn',@(h,e) this.MouseUp(h,e),'WindowButtonMotionFcn',@(h,e) this.MouseMove(h,e));
            end
        end
        function MouseMove(this,~,~)
            if this.CLICK_ON
                pt = get(this.hAx, 'CurrentPoint');
                this.pX(this.MOVE_PT) = pt(1,1);
                this.pY(this.MOVE_PT) = pt(1,2);

                [qx,qy] = crspline.CRline(this.pX,this.pY,100,this.Tension);
                try
                set(this.hLine,'xdata',qx,'ydata',qy');
                catch
                end
            end
        end

        function MouseUp(this,~,~)
            if this.CLICK_ON
                try
                    set(this.hPts,'xdata',this.pX,'ydata',this.pY);
                catch
                end
            end

            %update segments
            segs = this.MOVE_PT-2:this.MOVE_PT+1;
            segs(segs<1|segs>numel(this.pX)-1)=[];
            for sn=segs
                [qx,qy]=crspline.CRseg(this.pX,this.pY,sn,this.Tension);
                try
                set(this.hSeg(sn),'xdata',qx,'ydata',qy);
                catch
                end
            end

            this.CLICK_ON = false;
            hFig = get(this.hAx,'parent');
            set(hFig,'WindowButtonMotionFcn',this.orig_MouseMove);
            set(hFig,'WindowButtonUpFcn',this.orig_MouseUp);
            
            %% Update external accessible XY data
            this.X = this.pX;
            this.Y = this.pY;
            
            %fire uieditcallback
            hgfeval(this.UIeditCallback,this,struct('Event','DragDone'));
        end

        function DeletePt(this,~,~)
            this.pX(this.MOVE_PT) = [];
            this.pY(this.MOVE_PT) = [];

            %update line
            this.update_draw();
            
            %% Update external accessible XY data
            this.X = this.pX;
            this.Y = this.pY;
            
            %fire uieditcallback
            hgfeval(this.UIeditCallback,this,struct('Event','DeletePt'));
        end

        function AddPt(this,h,e)
            if e.Button~=1
                return;
            end
            seg = getappdata(h,'SegID');

            %add point
            this.pX = [this.pX(1:seg);e.IntersectionPoint(1);this.pX(seg+1:end)];
            this.pY = [this.pY(1:seg);e.IntersectionPoint(2);this.pY(seg+1:end)];

            this.update_draw();

            %enable curve dragging
            this.MOVE_PT = seg+1;
            this.CLICK_ON = true;
            hFig = get(this.hAx,'parent');
            set(hFig,'WindowButtonUpFcn',@(h,e) this.MouseUp(h,e),'WindowButtonMotionFcn',@(h,e) this.MouseMove(h,e));
            
            %% Update external accessible XY data
            this.X = this.pX;
            this.Y = this.pY;
            
            %fire uieditcallback
            hgfeval(this.UIeditCallback,this,struct('Event','AddPt'));
        end
    end
    
    %% Static Methods
    methods (Static)
        function [X,Y,CR] = UIdefine(varargin)
            % define CR-spline graphically
            % Syntax:
            %    CR = crspline.UIdefine();
            %         crspline.UIdefine(num_points);
            %         crspline.UIdefine(fig/ax,__);
            %         crspline.UIdefine(__,'Name',Value);
            % Name,Value Pairs:
            %   'Parent',hPar: specify figure or axes to use
            %   'initialXY',[X,Y]: initial points to use.
            
            hFig = [];
            hAx = [];
            nPoints = Inf;
            %% handle inputs
            %check for parent first
            if ~isempty(varargin) &&~ischar(varargin{1})&&isscalar(varargin{1})&& ishghandle(varargin{1}) && ismember(varargin{1}.Type,{'figure','axes'})
                if strcmp(varargin{1}.Type,'axes')
                    hFig = get(varargin{1},'Parent');
                    hAx = varargin{1};
                else
                    hFig = varargin{1};
                    figure(hFig);
                    hAx = gca;
                end
                varargin{1} = [];
            end
            %check for nPoints
            if ~isempty(varargin) && isnumeric(varargin{1})
                assert(isscalar(varargin{1}),'Number of points must be scalar');
                
                nPoints = varargin{1};
                varargin{1}=[];
            end
            % parse
            p = inputParser;
            p.CaseSensitive = false;
            addParameter(p,'Parent',[],@(x) isempty(x)||ishghandle(x));
            addParameter(p,'InitialXY',[],@(x) isempty(x)||(ismatrix(x)&&size(x,2)==2));
            parse(p,varargin{:});
            if isempty(hAx)
                Parent = p.Results.Parent;
                if isempty(Parent)
                    Parent = gcf;
                end
                if strcmp(get(Parent,'Type'),'axes')
                    hFig = get(Parent,'Parent');
                    hAx = Parent;
                else
                    hFig = Parent;
                    figure(hFig);
                    hAx = gca;
                end
            end
            
            %% store original figure props
            origFigPropNames = {'KeyPressFcn','WindowButtonDownFcn','WindowButtonUpFcn','WindowButtonMotionFcn','UserData','Pointer'};
            origFigPropValues = get(hFig,origFigPropNames);
            wasHold = ishold(hAx);
            %% Create CR spline
            if ~isempty(p.Results.InitialXY)
                X = p.Results.InitialXY(:,1);
                Y = p.Results.InitialXY(:,2);
            else
                X = [];
                Y = [];
            end
            
            CR = crspline(X,Y);
            
            if ~isempty(X)
                hLine = plot(CR,'Parent',hAx,'Interactive',false);
                set(hLine,'pickableparts','none');
                lineOK = true;
            else
                hLine = plot(NaN,NaN,'-');
                set(hLine,'pickableparts','none');
                lineOK = false;
            end

            
            hPoints = line('XData',[X;NaN],...
                'YData',[Y;NaN],...
                'Parent',hAx,...
                'LineStyle','none',...
                'MarkerSize',8,...
                'MarkerFaceColor',hLine.Color,...
                'MarkerEdgeColor','none',...
                'Marker','s',...
                'pickableparts','none');
            
            %% initial values
            clickedPoints = 0;
            hFig.UserData = 'wait';
            
            %% Callback functions
            function MouseDown(~,~)
                pt = get(hAx, 'CurrentPoint');
                X = [X;pt(1,1)];
                Y = [Y;pt(1,2)];
                CR.X = X;
                CR.Y = Y;
                set(hPoints,'xdata',X,'ydata',Y);
                clickedPoints = clickedPoints + 1;
                if clickedPoints>nPoints
                    hFig.UserData = 'continue';
                end
                if numel(X)>1 && ~lineOK
                    hold(hAx,'on');
                    hLine2 = plot(CR,'Parent',hAx,'color',hLine.Color);
                    set(hLine2,'pickableparts','none');
                    lineOK = true;
                    try
                    delete(hLine);
                    catch
                    end
                    hLine = hLine2;
                end

            end
            function MouseMotion(~,~)
                pt = get(hAx, 'CurrentPoint');
                x = pt(1,1);
                y = pt(1,2);
                CR.X = [X;x];
                CR.Y = [Y;y];
            end
            function KeyPress(~,e)
                if strcmp(e.Key,'escape')||strcmp(e.Key,'return')
                    hFig.UserData = 'continue';
                end
            end
            %% set callbacks
            hFig.WindowButtonMotionFcn = @MouseMotion;
            hFig.WindowButtonDownFcn = @MouseDown;
            hFig.KeyPressFcn = @KeyPress;
            
            %% Create message
            hTxt = uicontrol(hFig,...
                'Style','text',...
                'String','Select node locations. Press return when done.',...
                'FontSize',16,...
                'Units','points',...
                'Position',[5,5,16*63/2,24],...
                'HorizontalAlignment','center',...
                'BackgroundColor',[1,1,1]);
            %% Change pointer
            hFig.Pointer = 'cross';
            %% wait for continue
            waitfor(hFig,'UserData','continue');
            
            %% Cleanup
            delete(hTxt);
            delete(hLine);
            delete(hPoints);
            set(hFig,origFigPropNames,origFigPropValues);
            if wasHold
                hold(hAx,'on');
            else
                hold(hAx,'off');
            end
            
            %% clear CR is not used
            if nargout<3
                delete(CR);
            end
        end
        
    end
    
    %% Static Calculations
    methods (Static)
        function [qX,qY] = CRline(X,Y,nPTS,T)
            %generate xy points for cr line
            if nargin<4
                T = 0.5;
            end
            if nargin<3
                nPTS = 100;
            end
            
            if isempty(X) || isempty(Y)
                qX = [];
                qY = [];
                return;
            end
            
            X = [X(1);X;X(end)];
            Y = [Y(1);Y;Y(end)];
            qX = [];
            qY = [];
            for n=1:numel(X)-3
                [x,y] = crspline.CR(X(n:n+3),Y(n:n+3),linspace(0,1,nPTS),T);
                qX=[qX;x];
                qY=[qY;y];
            end
        end

        function [qX,qY] = CRseg(X,Y,n,T)
            if nargin<4
                T = 0.5;
            end
            
            if n>=numel(X) || n<1
                error('wrong n');
            end


            if n<2
                X = [X(1);X];
                Y = [Y(1);Y];
            else
                n=n-1;
            end
            if n>numel(X)-3
                X = [X;X(end)];
                Y = [Y;Y(end)];
            end

            [qX,qY] = crspline.CR(X(n:n+3),Y(n:n+3),linspace(0,1,100),T);

        end

        function [qx,qy] = CR(X,Y,t,T)
            if nargin<4
                T = 0.5;
            end
            t=reshape(t,[],1);
            X = reshape(X,[],1);
            Y = reshape(Y,[],1);
            tMat = [ones(numel(t),1),t,t.^2,t.^3];

            CRmat = [0,1,0,0;...
                  -T,0,T,0;...
                  2*T,T-3,3-2*T,-T;...
                  -T,2-T,T-2,T];

            qx = tMat*CRmat*X;
            qy = tMat*CRmat*Y;
        end
    end
    
end

function restack(hAx,top_handles,bottom_handles)
%alternative to uistack, since it is very slow
% hAx: parent axes
%   top_handles: handles that should be brought to top
%   bottom_handler: handles that should be below top_handles

%get rid of invalid handles
top_handles(~ishghandle(top_handles)) = [];
bottom_handles(~ishghandle(bottom_handles)) = [];

%get list of all children
AllChildren = allchild(hAx);

%find locations of the top and bottom handles in the children list
topInd = find(ismember(AllChildren,top_handles));
bottomInd = find(ismember(AllChildren,bottom_handles));

%make an order list of both handle sets
indList = [topInd;bottomInd];
orderedInd = sort(indList);

%shuffle the handles, with top before bottom
AllChildren(orderedInd) = AllChildren(indList);

set(hAx,'Children',AllChildren);
    
end

