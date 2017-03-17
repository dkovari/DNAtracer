function SegData = UIcreateNewSegment(this)
% TracePlot method for graphically defining a new segment

%% Bring plot to focus
hFig = this.showFigure();
figure(hFig);

state = uisuspend(hFig);

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

%% Create New CR Spline
[X,Y] = crspline.UIdefine('Parent',this.hAx);

SegData = struct('XY',[],'cspline',[],'CRnodes',struct('X',X,'Y',Y));
%% Cleanup
try
   uirestore(state);
catch
end

