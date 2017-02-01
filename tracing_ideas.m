% Tracing Routine Tester


close all;
clear all;
%% load image
if ~exist('LastDir','var')
    LastDir = [];
end
[FileName,PathName] = uigetfile({'*.001;*.003','Nanoscope Files';'*.*','All Files (*.*)'},'Select Nanoscope File',fullfile(LastDir,'*.001'));

if FileName == 0
    return;
end
LastDir = PathName;
filename = fullfile(PathName,FileName);

% file get info
NS_data = DIreader.get_NS_file_info(filename);


if isempty(NS_data)
    error('The specified file did not contain any images');
end
%get only height image
NS_data = NS_data(strcmpi('Height',{NS_data.type}));
if isempty(NS_data)
    error('Image does not contain height');
end
im_data = DIreader.get_NS_img_data(NS_data(1), 1); %read the data

%% Flatten Image
% figure();
% imagesc(im_data);
% title('Raw Image');
% axis image
%parabolic flatten
[xx,yy] = meshgrid(1:size(im_data,2),1:size(im_data,1));
xx=reshape(xx,[],1);
yy = reshape(yy,[],1);
XYmat = [xx.^2,xx,yy.^2,yy,ones(numel(im_data),1)];
A = mldivide(XYmat,reshape(im_data,[],1));
% Z = [X^2,X,Y^2,Y,1]*[A1,A2,A3,A4,A5]';

im_data_flat = reshape(im_data,[],1)-XYmat*A;
im_data_flat = reshape(im_data_flat,size(im_data));

% figure()
% imagesc(im_data_flat);
% title('paraboloid flattened');
% axis image
%% Estimate Threshold 

im_data_flat = im_data_flat - min(im_data_flat(:)); %shift so lowest value is zero

%remove noise with wiener filter
im_data_flat = wiener2(im_data_flat,5);

mIm = nanmean(im_data_flat(:));

[Counts,edges] = histcounts(im_data_flat(:));
% [X,Y] = edges2stairs(edges,Counts);
% lY = log10(Y);
% lY(Y==0) = 0;
% figure();
% plot(X,lY,'-k','linewidth',1.5);
% 
% hold on;

%fit lower-end data to a gaussian distribution
[muhat,sighat] = normfit(im_data_flat(im_data_flat<2*mIm));
% x=linspace(0,2*mIm,100);
% y = log10(max(Counts)*exp(-(x-muhat).^2./(2*sighat^2)));
% plot(x,y,'--');

% a good threshold seems to be mu+2*sigma
th = muhat+2*sighat;

% YL = get(gca,'ylim');
% plot([th,th],YL,'-.r');

%make binary
bin_data = im_data_flat>th;

%% filter data
%thow out small junk
bin_data = bwareafilt(bin_data,[40,Inf]);

%clear objects on edge
bin_data = imclearborder(bin_data);

% figure();
% imagesc(bin_data);
% axis image
% title('binary filtered');


%constuct a blured mask to use as a filter for the image data
%mask_data = gaussian_filter(double(imdilate(bin_data,ones(3))),5,15);
mask_data = radial_blur(double(bin_data),3);
% figure();
% imagesc(mask_data);
% axis image
% title('blured mask')

%make a filtered image using mask
im_filt = im_data_flat.*mask_data;
% figure();
% imagesc(im_filt);
% axis image
% title('Original with blured mask');
%% ID Objects
CC = bwconncomp(bin_data);
%each object is defined by each cell in the pixel list: CC.PixelIdxList

%% Apply Ridge filter using identified traces
R = ridgefilt_idx(im_filt,CC.PixelIdxList);

% figure();
% imagesc(R);
% axis image;
% title('ridge filter')

%% Trace using HW's code

THRESH = 0.12;
IM = R;

MoleculeData(numel(CC.PixelIdxList)) = struct('YX',[],'SubImg',[]);

for n=1:numel(CC.PixelIdxList)
    [ROWS,COLS] = ind2sub(size(IM),CC.PixelIdxList{n});
    
    SUBS = [min(ROWS),min(COLS);max(ROWS),max(COLS)];
    MoleculeData(n).SubImg = SUBS;
    
    ind2 = sub2ind(diff(SUBS,1,1)+1,ROWS-SUBS(1,1)+1,COLS-SUBS(1,2)+1);
    
    SI = zeros(diff(SUBS,1,1)+1);
    SI(ind2) = IM(CC.PixelIdxList{n});
    
    MoleculeData(n).YX = trace_HW(SI,THRESH);
    
    for j=1:numel(MoleculeData(n).YX)
        if ~isempty(MoleculeData(n).YX{j})
            MoleculeData(n).YX{j} = bsxfun(@plus,MoleculeData(n).YX{j},SUBS(1,:));
        end
    end
    
end

%% Plot all the lines 
figure(99);clf;
imagesc(im_data_flat);
axis image;
colormap gray;
hold on;

colors = lines(numel(MoleculeData));
for n=1:numel(MoleculeData)
    for j=1:numel(MoleculeData(n).YX)
        if ~isempty(MoleculeData(n).YX{j})
            plot(MoleculeData(n).YX{j}(:,2)-1,MoleculeData(n).YX{j}(:,1)-1,'-','color',colors(n,:));
            
            %endpoints
            plot(MoleculeData(n).YX{j}(1,2)-1,MoleculeData(n).YX{j}(1,1)-1,'s','color',colors(n,:));
            plot(MoleculeData(n).YX{j}(end,2)-1,MoleculeData(n).YX{j}(end,1)-1,'^','color',colors(n,:));
        end
    end
end




