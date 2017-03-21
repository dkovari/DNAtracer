function TraceData = processAFMImage(filepath) 
% process afm images

%% Load Packages
import TraceHelpers.*;

%% Prompt for molecule cutoff size
needSize = true;
defaultAns = {'200','Inf'};
while needSize
    answer = inputdlg({'Minimum Size [nm]';'Maximum Size [nm]'},'Molecule Size',1,{'200','Inf'});
    needSize=false;
    MinSize = str2double(answer{1});
    if isnan(MinSize)
        needSize = true;
    else
        defaultAns{1} = num2str(MinSize);
    end
    MaxSize = str2double(answer{2});
    if isnan(MinSize)
        needSize = true;
    else
        defaultAns{2} = num2str(MaxSize);
    end
end

%% Run DNA Trace
TraceData = DNAtracer(filepath,'Display',false,'MinSize',MinSize,'MaxSize',MaxSize);

%% Waitbar
hWait = waitbar(0,'Constructing Catmull-Rom Splines');

%% Construct CR-Spline for each molecule segment

%Finit Difference Coefficients
D1 = [1/280	-4/105	1/5	-4/5	0	4/5	-1/5	4/105	-1/280];
D2 = [-1/560	8/315	-1/5	8/5	-205/72	8/5	-1/5	8/315	-1/560];


for n=1:numel(TraceData.MoleculeData)
    
    for j=1:numel(TraceData.MoleculeData(n).Segment)
        
        XY = TraceData.MoleculeData(n).Segment(j).XY;
        %S = cumsum(sqrt(sum(diff(XY,1,1).^2,2)),1);
        %S = [0;S];
        S = 1:size(XY,1);
        pp = csaps(S,XY',0.5);

        TraceData.MoleculeData(n).Segment(j).cspline.s = S;
        TraceData.MoleculeData(n).Segment(j).cspline.pp = pp;

        S = TraceData.MoleculeData(n).Segment(j).cspline.s;
        XY = fnval(TraceData.MoleculeData(n).Segment(j).cspline.pp,S)'; %xy points of segments from cspline
        
        dXY = filter(D1,1,XY);
        ddXY = filter(D2,1,XY);
        
        %curvature
        k2 = ((dXY(:,1).*ddXY(:,2) - dXY(:,2).*ddXY(:,1))./(dXY(:,1).^2 + dXY(:,2).^2).^(3/2)).^2;
        k2=k2(5:end); %filter shifts to the right, correct that
        %find peaks in curvature to detemine CR-Spline node locations
        [~,locs] = findpeaks(k2,'MinPeakDistance',2,'MinPeakProminence',0.01);

        
        %Add end points to list of node if needed
        if ~ismember(1,locs)
            locs = [1;locs];
        end
        if ~ismember(numel(S),locs)
            locs=[locs;numel(S)];
        end
        
        %Create Catmull-Rom nodes
        TraceData.MoleculeData(n).Segment(j).CRnodes.X = XY(locs,1);
        TraceData.MoleculeData(n).Segment(j).CRnodes.Y = XY(locs,2);
  
    end
    
    
    try
        waitbar(n/numel(TraceData.MoleculeData),hWait);
    catch
    end
end

%% Delete waitbar
try
    delete(hWait);
catch
end