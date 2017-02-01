function R = ridgefilt_idx(im,idx)
% Apply ridge-finding filter to image at specified index locations.
%
% The function uses the eigenvalues of the Hessian of the image to
% determine pixels that correspond with ridge-lines of image intensity.
%
% The filter is only applied to the pixels specified by the indicies in
% IDX.
%
% Input:
%   im: 2D array containing a grayscale image
%   idx: numeric array or cell array of numeric arrays containing the pixel
%   locations at which the ridge-line filter should be applied.
%       NOTE: Indicies must be valid for size(im) arrays.
%
% Output:
%   R: A "ridge-line" image the same size as im
%
% Details:
%   The algorithm applies 5-point second-derivatives Dxx, Dyy, Dxy in the 
%   region around each pixel. Then calculates the eigenvalue of the
%   hessian:
%       [Dxx, Dxy;
%        Dxy, Dyy]
%   Each R(idx) contains the negative of the leading eigenvalue;
%
%% Copyright 2017, Daniel T. Kovari, Emory University
% All rights reserved

%% Change Log:
%   2017-01-31: DTK
%       Initial creation

%%
if ~iscell(idx)
    idx = {idx};
end

R = zeros(size(im));

% coefficients
[xx,yy] = meshgrid(-2:2,-2:2);
xx = xx(:);
yy = yy(:);
M = [xx.^2,yy.^2,xx.*yy,xx,yy,ones(25,1)];
invM = (M'*M)^-1*M';

dxx = reshape(2*invM(1,:),5,5);
dyy = reshape(2*invM(2,:),5,5);
dxy = reshape(invM(3,:),5,5);

for c = 1:numel(idx)
    for p=1:numel(idx{c})
        [row,col] = ind2sub(size(im),idx{c}(p));
        
        ROWS = row-2:row+2;
        COLS = col-2:col+2;
        
        dR = 1:5;
        dC = 1:5;
        
        nR = find(ROWS<1|ROWS>size(im,1));
        nC = find(COLS<1|COLS>size(im,2));
        
        dR(nR) = [];
        ROWS(nR) = [];
        dC(nC) = [];
        COLS(nC) = [];
        
        F = im(ROWS,COLS);
        Hxx = sum(sum(dxx(dR,dC).*F));
        Hyy = sum(sum(dyy(dR,dC).*F));
        Hxy = sum(sum(dxy(dR,dC).*F));
        
        v = eig([Hxx,Hxy;Hxy,Hyy]);
        R(idx{c}(p)) = -v(1);
    end
end
