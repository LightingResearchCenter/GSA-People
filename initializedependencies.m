function initializedependencies
%INITIALIZEDEPENDENCIES Add necessary repos to working path
%   Detailed explanation goes here

% Find full path to github directory
[githubDir,~,~] = fileparts(pwd);

% Construct repo paths
circadianPath   = fullfile(githubDir,'circadian');
cdfPath         = fullfile(githubDir,'LRC-CDFtoolkit');
phasorPath      = fullfile(githubDir,'PhasorAnalysis');
sleepPath       = fullfile(githubDir,'DaysimeterSleepAlgorithm');
% daysigramPath   = fullfile(githubDir,'DaysigramReport');
lightHealthPath = fullfile(githubDir,'LHIReport');
croppingPath    = fullfile(githubDir,'DaysimeterCropToolkit');
dfaPath         = fullfile(githubDir,'DetrendedFluctuationAnalysis');

% Enable repos
addpath(circadianPath,cdfPath,phasorPath,sleepPath,lightHealthPath,croppingPath,dfaPath);

end

