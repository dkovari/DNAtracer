function [filepath] = NanoscopeLoader(varargin)

%% Persistent and Globals
persistent LastDir;

%% Parse Inputs
p = inputParser;

addParameter(p,'Filepath',[]);
addParameter(p,'Interactive',true,@isscalar);

parse(p,varargin{:});

%% Set Processing Parameters

%% Load File
filepath = p.Results.Filepath;
if isempty(filepath)
    num_ext = sprintf('*.%03d;',1:999); %create extension list: '*.001;*.002;...'
    num_ext(end) = []; %get rid of dangling ';'
    [FileName,PathName] = uigetfile({num_ext,'Nanoscope Files (*.###)';...
                                    '*.*','All Files (*.*)'},...
                                    'Select Nanoscope Image File',...
                                    fullfile(LastDir,'*.001'));
    %do nothing if canceled
    if FileName == 0
        return;
    end
    filepath = fullfile(PathName,FileName);
end
[LastDir,~,~] = fileparts(filepath);

%% Interactively choose processing parameters
if p.Results.Interactive
    
