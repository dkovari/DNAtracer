function [TraceData,PathName,FileName] = DNAtracer(filename,varargin)
% DNAtracer - Trace DNA molecules in an AFM image
%
% Input:
%   filename:   nanoscope file to trace (*.001 or *.003 format)
%               If filename=[] (or no arguemnts are specified) then the
%               program will prompt the user to select a file.
% Parameters:
%   'Display',true/false    Plot image data and traces
%   'Parent',hPar   Graphics handle to draw on if Display=true

%% Import packages
import DIreader.*
%% Load image
persistent LastDir;
if nargin<1 || isempty(filename)
    [FileName,PathName] = uigetfile({'*.001;*.003','Nanoscope Files';'*.*','All Files (*.*)'},'Select Nanoscope File',fullfile(LastDir,'*.001'));
    if FileName == 0
        return;
    end
    LastDir = PathName;
    filename = fullfile(PathName,FileName);
end

[PathName,F_name,~] = fileparts(filename);

NS_data = get_NS_file_info(filename);

if isempty(NS_data)
    error('The specified file did not contain any images');
end

%get only height image
NS_data = NS_data(strcmpi('Height',{NS_data.type}));
if isempty(NS_data)
    error('Image does not contain height');
end
im_data = get_NS_img_data(NS_data(1), 1); %read the data


%% Parse Parameters
p=inputParser;
p.CaseSensitive = false;

addParameter(p,'Display',true,@(x) isscalar(x));
addParameter(p,'Parent',[],@(x) isempty(x)||ishghandle(x));

parse(p,varargin{:});

if p.Results.Display
    if ~isempty(p.Results.Parent)
        if strcmpi('figure',get(p.Results.Parent,'type'))
            figure(p.Results.Parent);
            hAx = gca;
        elseif strcmpi('axes',get(p.Results.Parent,'type'))
            hAx = p.Results.Parent;
        else
            warning('Specified parent is neither an Axes nor Figure. Uisng gca()');
            hAx = gca;
        end
    else
        figure();
        hAx = gca;
    end
end

%% Flatten Image
[xx,yy] = meshgrid(1:size(im_data,2),1:size(im_data,1));
xx=reshape(xx,[],1);
yy = reshape(yy,[],1);
XYmat = [xx.^2,xx,yy.^2,yy,ones(numel(im_data),1)];
A = mldivide(XYmat,reshape(im_data,[],1));

im_data_flat = reshape(im_data,[],1)-XYmat*A;
im_data_flat = reshape(im_data_flat,size(im_data));


%% Estimate Threshold 
im_data_flat = im_data_flat - min(im_data_flat(:)); %shift so lowest value is zero
%remove noise with wiener filter
im_data_flat = wiener2(im_data_flat,5);
mIm = nanmean(im_data_flat(:));

%fit lower-end data to a gaussian distribution
[muhat,sighat] = normfit(im_data_flat(im_data_flat<2*mIm));

% a good threshold seems to be mu+2*sigma
th = muhat+2*sighat;

%make binary
bin_data = im_data_flat>th;

%% filter data to remove small junk
%thow out small junk
bin_data = bwareafilt(bin_data,[40,Inf]);

%clear objects on edge
bin_data = imclearborder(bin_data);

%constuct a blured mask to use as a filter for the image data
%mask_data = gaussian_filter(double(imdilate(bin_data,ones(3))),5,15);
mask_data = radial_blur(double(bin_data),3);

%make a filtered image using mask
im_filt = im_data_flat.*mask_data;

%% ID Objects
CC = bwconncomp(bin_data);
%each object is defined by each cell in the pixel list: CC.PixelIdxList

%% Apply Ridge filter using identified traces
R = ridgefilt_idx(im_filt,CC.PixelIdxList);

%% Trace using HW's code
IM = R; %image data to use in tracing, could change this to im_filt
THRESH = 0.12; %threshold to use, if using im_filt this should be "th"

MoleculeData(numel(CC.PixelIdxList)) = struct('SubImg',[],'PixelIdxList',[],'Segment',[]);

for n=1:numel(CC.PixelIdxList)
    MoleculeData(n).PixelIdxList = CC.PixelIdxList{n};
    
    [ROWS,COLS] = ind2sub(size(IM),CC.PixelIdxList{n});
    
    SUBS = [min(ROWS),min(COLS);max(ROWS),max(COLS)];
    MoleculeData(n).SubImg = SUBS;
    
    ind2 = sub2ind(diff(SUBS,1,1)+1,ROWS-SUBS(1,1)+1,COLS-SUBS(1,2)+1);
    
    SI = zeros(diff(SUBS,1,1)+1);
    SI(ind2) = IM(CC.PixelIdxList{n});
    
    YX = trace_HW(SI,THRESH); %compute molecule segments
    
    % assemble MoleculeData Structure from segments
    segcount = 0;
    for j=1:numel(YX)
        if ~isempty(YX{j}) %only keep segments that contain data, in testing HW's code returned empty data sometimes
            segcount = segcount+1;
            MoleculeData(n).Segment(segcount).XY = fliplr(bsxfun(@plus,YX{j},SUBS(1,:)))-1; %shift back to index relative to entire image and correct for pixel shift
        end
    end
    
end

%% Plot all the lines 
if p.Results.Display
    imagesc(hAx,im_data_flat);
    axis(hAx,'image');
    colormap(hAx,'gray');
    washold = ishold(hAx);
    hold(hAx,'on');

    colors = lines(numel(MoleculeData));
    hLines = gobjects(numel(MoleculeData),1);
    for n=1:numel(MoleculeData)
        for j=1:numel(MoleculeData(n).Segment)
            hLn = plot(MoleculeData(n).Segment(j).XY(:,1),MoleculeData(n).Segment(j).XY(:,2),'-','color',colors(n,:));

            %endpoints
            plot(MoleculeData(n).Segment(j).XY(1,1),MoleculeData(n).Segment(j).XY(1,2),'s','color',colors(n,:));
            plot(MoleculeData(n).Segment(j).XY(end,1),MoleculeData(n).Segment(j).XY(end,2),'^','color',colors(n,:));
            
            if j==1 %set handle to line for legend
                hLines(n) = hLn;
            end
        end
    end
    legend(hAx,hLines,cell_sprintf('Molecule %d',1:numel(MoleculeData)),'location','northeastoutside');
    if ~washold
        hold(hAx,'off');
    end
end
%% Assemble data into Structure
TraceData.NS_data = NS_data;
TraceData.im_data = im_data;
TraceData.im_data_flat = im_data_flat;
TraceData.im_filt = im_filt;
TraceData.bin_data = bin_data;
TraceData.RidgeImage = R;

TraceData.MoleculeData = MoleculeData;

%% Save

%% Clear data if no output
if nargout<1
    clear TraceData;
end
end

function c = cell_sprintf(format,data)
% sprintf with cellstr array output
%   format: c-style format string
%   data: array of data to use in formatted string

c = {};
for dataElement = data
    c{end+1} = sprintf(format,dataElement);
end
end
