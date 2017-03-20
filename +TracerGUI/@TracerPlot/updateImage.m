function updateImage(this)
%tracePlot method to update the plot image
if ~ishghandle(this.hFig)
    return;
end

try
    set(this.hImg,'cdata',this.traceDataHandler.im_data_flat);
    zoom(this.hFig,'out');
catch
end