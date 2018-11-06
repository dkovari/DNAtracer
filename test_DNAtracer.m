[TraceData,PathName,FileName] = TraceHelpers.DNAtracer([],'Display',true,'MinSize',200);


%while true
    %% choose molecule
    answer = inputdlg(sprintf('Select molecule (%d-%d)',1,numel(TraceData.MoleculeData)),'MoleculeID',1,{'1'});
    if isempty(answer)
        return;
    end

    MOL_ID = str2num(answer{1});

    %% show molecule
    SUB_RANGE = TraceData.MoleculeData(MOL_ID).SubImg;
    MOL_IMG = TraceData.im_data(SUB_RANGE(1,1):SUB_RANGE(2,1),SUB_RANGE(1,2):SUB_RANGE(2,2));

    hFig = figure;
    imagesc(SUB_RANGE(:,2),SUB_RANGE(:,1),MOL_IMG);
    axis image;
    title(sprintf('Molecule %d',MOL_ID));
    hold on;
    %% plot molecule trace
    for n = 1:numel(TraceData.MoleculeData(MOL_ID).Segment)
        plot(TraceData.MoleculeData(MOL_ID).Segment(n).XY(:,1),TraceData.MoleculeData(MOL_ID).Segment(n).XY(:,2),'-');
    end
    
%     answer = questdlg('Plot another molecule?','Plot more?','Yes','No','No');
%     if strcmpi(answer,'No')
%         break;
%     end
%end
    
