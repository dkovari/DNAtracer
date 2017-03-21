function R = ridgefilter(im)

[Hxx,Hyy,Hxy] = Hess5x5(im);
R = zeros(size(im));
for n=1:numel(im)
    v = eig([Hxx(n),Hxy(n);Hxy(n),Hyy(n)]);
    R(n) = -v(1);

end


function [Hxx,Hyy,Hxy] = Hess9(im)

[xx,yy] = meshgrid(-1:1,-1:1);
xx = xx(:);
yy = yy(:);
M = [xx.^2,yy.^2,xx.*yy,xx,yy,ones(9,1)];
invM = (M'*M)^-1*M';

Hxx = filter2(reshape(2*invM(1,:),3,3),im);
Hyy = filter2(reshape(2*invM(2,:),3,3),im);
Hxy = filter2(reshape(invM(3,:),3,3),im);

function [Hxx,Hyy,Hxy] = Hess5x5(im)

[xx,yy] = meshgrid(-2:2,-2:2);
xx = xx(:);
yy = yy(:);
M = [xx.^2,yy.^2,xx.*yy,xx,yy,ones(25,1)];
invM = (M'*M)^-1*M';

Hxx = filter2(reshape(2*invM(1,:),5,5),im);
Hyy = filter2(reshape(2*invM(2,:),5,5),im);
Hxy = filter2(reshape(invM(3,:),5,5),im);

