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
%%    
    properties (SetObservable = true)
        X; %xpoints
        Y; %ypoints
        Tension=0.5;
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
        
        InteractivePlot;
        
        orig_MouseMove;
        orig_MouseUp;
    end
    
    %x
    properties(Access=private,Dependent=true)
        pltX;
        pltY;
    end
    methods
        function X = get.pltX(this)
            if numel(this.X)<numel(this.Y)
                X = [this.X;NaN(numel(this.Y)-numel(this.X),1)];
            else
                X=this.X;
            end
        end
        function Y = get.pltY(this)
            if numel(this.Y)<numel(this.X)
                Y = [this.Y;NaN(numel(this.X)-numel(this.Y),1)];
            else
                Y=this.Y;
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
            this.X = reshape(X,[],1);
            this.Y = reshape(Y,[],1);
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
            [qX,qY] = crspline.CRline(this.X,this.Y,500,this.Tension);
            L = sum(sqrt(diff(qX).^2+diff(qY).^2));
        end
    end
    
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
                    if S_data(n)<0||S_data(n)>numel(this.X)-1
                        continue;
                    end

                    if ~mod(S_data(n),1)
                        qX(n) = this.X(S+data(n)+1);
                        qY(n) = this.Y(S+data(n)+1);
                        continue;
                    end

                    seg = ceil(S_data(n));
                    s = S_data(n)-seg+1;

                    X = this.X;
                    Y = this.Y;

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
                    hPts = line('xdata',this.pltX,'ydata',this.pltY,'parent',this.hAx,'LineStyle','none','marker','s','markeredgecolor',get(hLine,'color'),'markerfacecolor',get(hLine,'Color'),'markersize',8);
                end
            end
            
            if p.Results.Interactive
                % Create hidden segment lines, for adding points to the
                % curve
                this.hSeg = gobjects(numel(this.X)-1,1);
                for n = 1:numel(this.X)-1
                    [qX,qY] = crspline.CRseg(this.X,this.Y,n);
                    this.hSeg(n) = line(qX,qY,'visible','off','pickableparts','all','ButtonDownFcn',@(h,e) this.AddPt(h,e));
                    setappdata(this.hSeg(n),'SegID',n);
                end
                
                %callbacks for moving points
                set(hPts,'ButtonDownFcn',@(h,e) this.MouseClick(h,e));
                
                
                %delete points menu
                hMenu = uicontextmenu();
                hPts.UIContextMenu = hMenu;
                uimenu(hMenu,'label','Delete Point','callback',@(h,e) this.DeletePt(h,e));

            end

            %% Set Object properties
            this.InteractivePlot = p.Results.Interactive;
            this.hLine = hLine;
            this.hPts = hPts;
            %move points to top
            uistack(this.hPts,'top');
        end
        
    end
    
    %get/set methods
    methods
        function set.X(this,X)
            this.X = reshape(X,[],1);
            this.update_draw();
        end
        function set.Y(this,Y)
            this.Y = reshape(Y,[],1);
            this.update_draw();
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
    end
    
    %internal
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
            try
                set(this.hPts,'xdata',this.pltX,'ydata',this.pltY);
            catch
            end
            %update hidden segments
            try
                delete(this.hSeg);
            catch
            end
            this.hSeg = gobjects(numel(this.pltX)-1,1);
            for sn = 1:numel(this.pltX)-1
                [qX,qY] = crspline.CRseg(this.pltX,this.pltY,sn,this.Tension);
                this.hSeg(sn) = line(qX,qY,'parent',this.hAx,'visible','off','pickableparts','all','ButtonDownFcn',@(h,e) this.AddPt(h,e));
                setappdata(this.hSeg(sn),'SegID',sn);
            end

            %put points back on top
            uistack(this.hPts,'top');
        end
    end

    methods %callbacks
        function MouseClick(this,~,e)
            [~,this.MOVE_PT] = min( (this.X-e.IntersectionPoint(1)).^2 + (this.Y-e.IntersectionPoint(2)).^2);
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
                this.X(this.MOVE_PT) = pt(1,1);
                this.Y(this.MOVE_PT) = pt(1,2);

                [qx,qy] = crspline.CRline(this.X,this.Y,100,this.Tension);
                try
                set(this.hLine,'xdata',qx,'ydata',qy');
                catch
                end
            end
        end

        function MouseUp(this,~,~)
            if this.CLICK_ON
                try
                    set(this.hPts,'xdata',this.X,'ydata',this.Y);
                catch
                end
            end

            %update segments
            segs = this.MOVE_PT-2:this.MOVE_PT+1;
            segs(segs<1|segs>numel(this.X)-1)=[];
            for sn=segs
                [qx,qy]=crspline.CRseg(this.X,this.Y,sn,this.Tension);
                try
                set(this.hSeg(sn),'xdata',qx,'ydata',qy);
                catch
                end
            end

            this.CLICK_ON = false;
            hFig = get(this.hAx,'parent');
            set(hFig,'WindowButtonMotionFcn',this.orig_MouseMove);
            set(hFig,'WindowButtonUpFcn',this.orig_MouseUp);
            
            %fire uieditcallback
            hgfeval(this.UIeditCallback,this,struct('Event','DragDone'));
        end

        function DeletePt(this,~,~)
            this.X(this.MOVE_PT) = [];
            this.Y(this.MOVE_PT) = [];

            %update line
            this.update_draw();
            
            %fire uieditcallback
            hgfeval(this.UIeditCallback,this,struct('Event','DeletePt'));
        end

        function AddPt(this,h,e)
            if e.Button~=1
                return;
            end
            seg = getappdata(h,'SegID');

            %add point
            this.X = [this.X(1:seg);e.IntersectionPoint(1);this.X(seg+1:end)];
            this.Y = [this.Y(1:seg);e.IntersectionPoint(2);this.Y(seg+1:end)];

            this.update_draw();

            %enable curve dragging
            this.MOVE_PT = seg+1;
            this.CLICK_ON = true;
            hFig = get(this.hAx,'parent');
            set(hFig,'WindowButtonUpFcn',@(h,e) this.MouseUp(h,e),'WindowButtonMotionFcn',@(h,e) this.MouseMove(h,e));
            
            %fire uieditcallback
            hgfeval(this.UIeditCallback,this,struct('Event','AddPt'));
        end
    end
    
    methods (Static)
        function [qX,qY] = CRline(X,Y,nPTS,T)
            if nargin<4
                T = 0.5;
            end
            if nargin<3
                nPTS = 100;
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

            [qX,qY] = crspline.CR(X(n:n+3),Y(n:n+3),linspace(0.05,0.95,100),T);

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

