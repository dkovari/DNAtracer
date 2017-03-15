function [TraceData,pth,fn] = processAFMImage()
% TraceData Structure:
%  TraceData.ND_data
%       .im_data
%       .im_data_flat
%       .im_flat
%       .bin_data
%       .RidgeImage
%       .MoleculeData().
%           .SubImg
%           .PixelIdxList
%           .Segment()
%               .XY
%               .cspline
%               .CRnodes
%                   .X
%                   .Y

[TraceData,PathName,FileName] = DNAtracer([],'Display',false);

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
end

%% Save?
answer = questdlg('Save processed data as *.mat?','Save?','Yes','No','Yes');
pth = [];
fn = [];
if strcmpi(answer,'Yes')
    [~,f,~] = fileparts(FileName);
    [fn,pth] = uiputfile('*.mat','Save Trace Data As...',fullfile(PathName,[f,'.mat']));
    if fn==0
        return;
    end
    save(fullfile(pth,fn),'-mat','-struct','TraceData');
end
    