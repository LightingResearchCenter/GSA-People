function dfatrial
%DFATRIAL Detrended Fluctuation Analysis trial
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% % Open the pool
% if isempty(gcp('nocreate'))
%     parpool;
% end

% Have user select project location and session
[plainLocation,displayLocation] = gui_locationselect;
[plainSession ,displaySession ] = gui_sessionselect ;

% Construct project paths
Paths = initializepaths(plainLocation,plainSession);
[~,cdfPathArray] = searchdir(Paths.editedData,'cdf');

% Preallocate and intialize resources
nFiles          = numel(cdfPathArray);
order           = 1;
timeScaleRange  = [duration(1,30,0),duration(8,0,0)];
templateCell    = cell(nFiles,1);

subject  = templateCell;
alpha    = templateCell;

for i1 = 1:nFiles
    % Import data
    Data = ProcessCDF(cdfPathArray{i1});
    currentSubject = Data.GlobalAttributes.subjectID{1};
    logicalArray = logical(Data.Variables.logicalArray);
    timeArray = Data.Variables.time(logicalArray);
    datetimeArray = datetime(timeArray,'ConvertFrom','datenum');
    activityArray = Data.Variables.activity(logicalArray);
    
    % Assign subject
    subject{i1} = currentSubject;
    
    % Check useable data
    if numel(timeArray) < 24
        continue
    end
    
    % Perform DFA
    h = figure;
    figureTitle = ['Subject ',currentSubject];
    alpha{i1} = dfa(datetimeArray,activityArray,order,timeScaleRange,h,figureTitle);
end

Output          = dataset;
Output.subject  = subject;
Output.alpha    = alpha;

outputCell = dataset2cell(Output);
varNameArray = outputCell(1,:);
prettyVarNameArray = lower(regexprep(varNameArray,'([^A-Z])([A-Z0-9])','$1 $2'));
outputCell(1,:) = prettyVarNameArray;

runtime = datestr(now,'yyyy-mm-dd_HHMM');
resultsPath = fullfile(Paths.results,['dfa-trial_',runtime,'_GSA_',plainLocation,'_',plainSession,'.xlsx']);
xlswrite(resultsPath,outputCell);

end

