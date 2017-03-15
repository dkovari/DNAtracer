clear all;
close all;
clc;

[traceData,pth,fn] = processAFMImage();

TracerGUI.TracerMain(traceData,fullfile(pth,fn));
