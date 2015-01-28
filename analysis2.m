function analysis2
%ANALYSIS2

% Enable dependecies
initializedependencies;

[githubDir,~,~] = fileparts(pwd);
circadianDir = fullfile(githubDir,'circadian');
addpath(circadianDir);

% Have user select project location and session
[plainLocation,displayLocation] = gui_locationselect;
[plainSession ,displaySession ] = gui_sessionselect ;

% Construct project paths
Paths = initializepaths(plainLocation,plainSession);
[~,cdfPathArray] = searchdir(Paths.editedData,'cdf');
[bedLogFileNameArray,bedLogPathArray] = searchdir(Paths.logs,'xlsx');

% Extract subject from bed logs
bedSubject = str2double(regexprep(bedLogFileNameArray,'.*(\d\d).*','$1'));

% Preallocate and intialize resources
[hFigure,~,~,units] = initializefigure1(1,'on');
nFiles = numel(cdfPathArray);
templateCell = cell(nFiles,1);

Output = dataset;
Output.subject = templateCell;
%   sleep
Output.nightsAveraged        = templateCell;
Output.actualSleepTimeMins   = templateCell;
Output.actualSleepPercent    = templateCell;
Output.actualWakeTimeMins    = templateCell;
Output.actualWakePercent     = templateCell;
Output.sleepEfficiency       = templateCell;
Output.sleepOnsetLatencyMins = templateCell;
Output.sleepBouts            = templateCell;
Output.wakeBouts             = templateCell;
Output.meanSleepBoutTimeMins = templateCell;
Output.meanWakeBoutTimeMins  = templateCell;
%   phasor, IS, IV
Output.phasorMagnitude       = templateCell;
Output.phasorAngleHrs        = templateCell;
Output.interdailyStability   = templateCell;
Output.intradailyVariability = templateCell;
%   averages (CS)
Output.arithmeticMeanNonZeroCs     = templateCell;
Output.arithmeticMeanWorkdayCs     = templateCell;
Output.arithmeticMeanPostWorkdayCs = templateCell;
%   averages (Lux)
Output.arithmeticMeanNonZeroLux     = templateCell;
Output.geometricMeanNonZeroLux      = templateCell;
Output.medianNonZeroLux             = templateCell;

Output.arithmeticMeanWorkdayLux     = templateCell;
Output.geometricMeanWorkdayLux      = templateCell;
Output.medianWorkdayLux             = templateCell;

Output.arithmeticMeanPostWorkdayLux = templateCell;
Output.geometricMeanPostWorkdayLux  = templateCell;
Output.medianPostWorkdayLux         = templateCell;
%   averages (Activity)
Output.arithmeticMeanNonZeroActivity     = templateCell;
Output.arithmeticMeanWorkdayActivity     = templateCell;
Output.arithmeticMeanPostWorkdayActivity = templateCell;


for i1 = 1:nFiles
    % Import data
    cdfData = daysimeter12.readcdf(cdfPathArray{i1});
    [absTime,relTime,epoch,light,activity,masks,subjectID,deviceSN] = daysimeter12.convertcdf(cdfData);
    
    logicalArray = masks.observation;
    complianceArray = masks.compliance(logicalArray);
    bedArray = masks.bed(logicalArray);
    timeArray = absTime.localDateNum(logicalArray);
    activityArray = activity(logicalArray);
    csArray = light.cs(logicalArray);
    illuminanceArray = light.illuminance(logicalArray);
    
    startTime = min(timeArray);
    stopTime = max(timeArray);
    idx = absTime.localDateNum > floor(startTime) & absTime.localDateNum < ceil(stopTime);
    masks2 = masks;
    masks2.observation = masks2.observation(idx);
    masks2.compliance = masks2.compliance(idx);
    masks2.bed = masks2.bed(idx);
    
    % Set subject
    Output.subject{i1,1} = subjectID;
    
    % Check useable data
    if numel(timeArray(complianceArray)) < 24
        continue
    end
    
    % Match and import bed log
    bedIdx = bedSubject == str2double(subjectID);
    [bedTimeArray,riseTimeArray] = importbedlog(bedLogPathArray{bedIdx});
    
    % Daysigram
    sheetTitle = ['GSA - ',displayLocation,' - ',displaySession,' - Subject ',subjectID];
    daysigramFileID = ['subject',subjectID];
%     reports.daysigram.daysigram(2,sheetTitle,absTime.localDateNum(idx),masks2,activity(idx),light.cs(idx),'cs',[0,1],8,Paths.plots,[daysigramFileID,'_CS']);
    reports.daysigram.daysigram(3,sheetTitle,absTime.localDateNum(idx),masks2,activity(idx),light.illuminance(idx),'lux',[1,10^5],8,Paths.plots,[daysigramFileID,'_Lux']);
    
    % Light and Health Report/ Phasor Analysis
    figTitle = ['GSA - ',displayLocation,' - ',displaySession];
    Phasor = phasorprep(subjectID,figTitle,hFigure,units,Paths,...
        complianceArray,bedArray,timeArray,csArray,activityArray,...
        illuminanceArray);
    
    % Averages
    [Average,WorkAverage,PostWorkAverage] = prepaverages(...
        timeArray,csArray,activityArray,illuminanceArray,...
        complianceArray,bedArray,bedTimeArray);
    
    % Sleep Analysis
    [Sleep,nIntervalsAveraged] = sleepprep(timeArray,activityArray,...
        bedTimeArray,riseTimeArray,complianceArray);
    
    % Assign output
    %   sleep
    Output.nightsAveraged{i1,1}         = nIntervalsAveraged;
    Output.actualSleepTimeMins{i1,1}    = Sleep.actualSleepTime;
    Output.actualSleepPercent{i1,1}     = Sleep.actualSleepPercent;
    Output.actualWakeTimeMins{i1,1}     = Sleep.actualWakeTime;
    Output.actualWakePercent{i1,1}      = Sleep.actualWakePercent;
    Output.sleepEfficiency{i1,1}        = Sleep.sleepEfficiency;
    Output.sleepOnsetLatencyMins{i1,1}  = Sleep.sleepLatency;
    Output.sleepBouts{i1,1}             = Sleep.sleepBouts;
    Output.wakeBouts{i1,1}              = Sleep.wakeBouts;
    Output.meanSleepBoutTimeMins{i1,1}  = Sleep.meanSleepBoutTime;
    Output.meanWakeBoutTimeMins{i1,1}   = Sleep.meanWakeBoutTime;

    %   phasor, IS, IV
    Output.phasorMagnitude{i1,1}        = Phasor.phasorMagnitude;
    Output.phasorAngleHrs{i1,1}         = Phasor.phasorAngleHrs;
    Output.interdailyStability{i1,1}    = Phasor.interdailyStability;
    Output.intradailyVariability{i1,1}  = Phasor.intradailyVariability;

    %   averages (CS)
    Output.arithmeticMeanNonZeroCs{i1,1}     = Average.cs.arithmeticMean;
    Output.arithmeticMeanWorkdayCs{i1,1}     = WorkAverage.cs.arithmeticMean;
    Output.arithmeticMeanPostWorkdayCs{i1,1} = PostWorkAverage.cs.arithmeticMean;
    %   averages (Lux)
    Output.arithmeticMeanNonZeroLux{i1,1}     = Average.illuminance.arithmeticMean;
    Output.geometricMeanNonZeroLux{i1,1}      = Average.illuminance.geometricMean;
    Output.medianNonZeroLux{i1,1}             = Average.illuminance.median;

    Output.arithmeticMeanWorkdayLux{i1,1}     = WorkAverage.illuminance.arithmeticMean;
    Output.geometricMeanWorkdayLux{i1,1}      = WorkAverage.illuminance.geometricMean;
    Output.medianWorkdayLux{i1,1}             = WorkAverage.illuminance.median;

    Output.arithmeticMeanPostWorkdayLux{i1,1} = PostWorkAverage.illuminance.arithmeticMean;
    Output.geometricMeanPostWorkdayLux{i1,1}  = PostWorkAverage.illuminance.geometricMean;
    Output.medianPostWorkdayLux{i1,1}         = PostWorkAverage.illuminance.median;
    %   averages (Activity)
    Output.arithmeticMeanNonZeroActivity{i1,1}     = Average.activity.arithmeticMean;
    Output.arithmeticMeanWorkdayActivity{i1,1}     = WorkAverage.activity.arithmeticMean;
    Output.arithmeticMeanPostWorkdayActivity{i1,1} = PostWorkAverage.activity.arithmeticMean;
end

close all

outputCell = dataset2cell(Output);
varNameArray = outputCell(1,:);
prettyVarNameArray = lower(regexprep(varNameArray,'([^A-Z])([A-Z0-9])','$1 $2'));
outputCell(1,:) = prettyVarNameArray;

runtime = datestr(now,'yyyy-mm-dd_HHMM');
resultsPath = fullfile(Paths.results,['results_',runtime,'_GSA_',plainLocation,'_',plainSession,'_sans-weekends','.xlsx']);
xlswrite(resultsPath,outputCell);

end


function Output = phasorprep(subject,figTitle,hFigure,units,Paths,complianceArray,bedArray,timeArray,csArray,activityArray,illuminanceArray)
clf;

wkendIdx = createweekend(timeArray);

% replace in bed time
csArray(bedArray) = 0;
activityArray(bedArray) = 0;
illuminanceArray(bedArray) = 0;

% remove only large noncompliance while awake
complianceArray = adjustcrop(timeArray,complianceArray,bedArray);
timeArray(~complianceArray | wkendIdx) = [];
csArray(~complianceArray | wkendIdx) = [];
activityArray(~complianceArray | wkendIdx) = [];
illuminanceArray(~complianceArray | wkendIdx) = [];

Output = generatereport(Paths.plots,timeArray,csArray,activityArray,...
    illuminanceArray,[subject,' sans-weekends'],hFigure,units,figTitle);
end


function wkendIdx = createweekend(timeArray)

dayArray        = floor(timeArray);
dayOfWeekArray	= weekday(dayArray); % Sunday = 1, Monday = 2, etc.
wkendIdx        = dayOfWeekArray == 1 | dayOfWeekArray == 7;

end

function [workIdx,postWorkIdx] = createworkday(timeArray,bedTimeArray)

workStart = 8/24;
workEnd   = 17/24;

dayArray       = unique(floor(timeArray));
dayOfWeekArray = weekday(dayArray); % Sunday = 1, Monday = 2, etc.
workDaysIdx    = dayOfWeekArray >= 2 & dayOfWeekArray <= 6;
workDayArray   = dayArray(workDaysIdx);

workStartArray = workDayArray + workStart;
workEndArray   = workDayArray + workEnd;

workIdx = false(size(timeArray));
postWorkIdx = false(size(timeArray));
for j1 = 1:numel(workStartArray)
    tempWorkIdx = timeArray > workStartArray(j1) & timeArray <= workEndArray(j1);
    workIdx = workIdx | tempWorkIdx;

    diffBedTime = bedTimeArray - workEndArray(j1);
    currentBedTime = bedTimeArray(diffBedTime<1 & diffBedTime>0);
    if numel(currentBedTime) == 1
        tempPostWorkIdx = timeArray > workEndArray(j1) & timeArray <=currentBedTime;
        postWorkIdx = postWorkIdx | tempPostWorkIdx;
    end
end

end


function [Average,WorkAverage,PostWorkAverage] = prepaverages(timeArray,csArray,activityArray,illuminanceArray,complianceArray,bedArray,bedTimeArray)

validIdx = complianceArray & ~bedArray;

timeArray(~validIdx) = [];
csArray(~validIdx) = [];
activityArray(~validIdx) = [];
illuminanceArray(~validIdx) = [];

[workIdx,postWorkIdx] = createworkday(timeArray,bedTimeArray);

Average = daysimeteraverages(csArray(csArray>0.01),illuminanceArray(illuminanceArray>0.01),activityArray(activityArray>0.01));
WorkAverage = daysimeteraverages(csArray(workIdx),...
    illuminanceArray(workIdx),activityArray(workIdx));
PostWorkAverage = daysimeteraverages(csArray(postWorkIdx),...
    illuminanceArray(postWorkIdx),activityArray(postWorkIdx));

end


function [Sleep,nIntervalsAveraged] = sleepprep(timeArray,activityArray,bedTimeArray,riseTimeArray,complianceArray)

timeArray(~complianceArray) = [];
activityArray(~complianceArray) = [];

analysisStartTimeArray = bedTimeArray  - 20/(60*24);
analysisEndTimeArray   = riseTimeArray + 20/(60*24);

startDayArray = floor(analysisStartTimeArray);
startDayOfWeekArray = weekday(startDayArray); % Sunday = 1, Monday = 2, etc.
wkendIdx = startDayOfWeekArray == 1 | startDayOfWeekArray == 7;

bedTimeArray(wkendIdx) = [];
riseTimeArray(wkendIdx) = [];
analysisStartTimeArray(wkendIdx) = [];
analysisEndTimeArray(wkendIdx) = [];

nIntervals = numel(bedTimeArray);
dailySleep = cell(nIntervals,1);
    
for i1 = 1:nIntervals
    % Perform analysis
    try
        dailySleep{i1} = sleepAnalysis(timeArray,activityArray,...
        analysisStartTimeArray(i1),analysisEndTimeArray(i1),...
        bedTimeArray(i1),riseTimeArray(i1),'auto');
    catch err
        continue
    end
end

% Average results
[Sleep,nIntervalsAveraged] = averageanalysis(dailySleep);

end