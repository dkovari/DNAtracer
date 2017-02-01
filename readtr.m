% This function read tracing file and return a matrix of coordinates of
% tracing.

function data = readtr(filename)
fd = fopen(filename);
data.tr=zeros(2,2);
i=1;

while feof(fd)==0
    DataIn=fscanf(fd, '%d %d', 2);

    if feof(fd)==1
        break;
    end
    if i==1 && DataIn(1)>0
        data.BASE=DataIn(1);
        data.OVERWHELM=DataIn(2);
        continue;
    end
    data.tr(i,1)=DataIn(1);
    data.tr(i,2)=DataIn(2);
    i=i+1;

end

fclose(fd);
