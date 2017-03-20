N = 100;
L = 4;
XY = rand(L,2,N);

figure();
gca;
hold on;


for n=N:-1:1
    CR(n) = crspline(XY(:,1,n),XY(:,2,n));
    plot(CR(n),'Interactive',false);
end

for n=1:10
    CR(n).Interactive = true;
end
