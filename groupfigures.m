function groupfigures
%GROUPFIGURES

runtime = datestr(now,'yyyy-mm-dd_HHMM');

% Enable dependecies
initializedependencies;

% Have user select project location and session
[plainLocation,displayLocation] = gui_locationselect;

% plainSeasonCell = {'summer','winter'};
% displaySeasonCell = {'Summer','Winter'};
plainSeasonCell = {'summer'};
displaySeasonCell = {'Summer'};

xTicks = [0,6/24,12/24,18/24,24/24];
yTicks = 0:.1:.7;

invalidSubjectArray = [6,9,16,20,25];

for i0 = 1:numel(plainSeasonCell)
    % Construct project paths
    Paths = initializepaths(plainLocation,plainSeasonCell{i0});
    [~,cdfPathArray] = searchdir(Paths.editedData,'cdf');


    % Preallocate and intialize resources
    nFiles = numel(cdfPathArray);
    templateMat  = zeros(nFiles,1);
    templateCell = cell(nFiles,1);
    phasorMagnitude     = templateMat;
    phasorAngleHrs      = templateMat;
    millerTime_seconds  = templateCell;
    millerCs            = templateCell;
    millerActivity      = templateCell;

    for i1 = 1:nFiles
        % Import data
        Data = ProcessCDF(cdfPathArray{i1});
        
        subject = str2double(Data.GlobalAttributes.subjectID{1});
        
        if any(subject == invalidSubjectArray);
            continue;
        end
        
        logicalArray = logical(Data.Variables.logicalArray);
        complianceArray = logical(Data.Variables.complianceArray(logicalArray));
        bedArray = logical(Data.Variables.bedArray(logicalArray));
        timeArray = Data.Variables.time(logicalArray);
        activityArray = Data.Variables.activity(logicalArray);
        csArray = Data.Variables.CS(logicalArray);
        
        % Check for useable data
        if numel(timeArray(complianceArray)) < 24
            continue
        end

        % Phasor Analysis
        [phasorMagnitude(i1),phasorAngleHrs(i1)] = phasorprep(...
            complianceArray,bedArray,timeArray,csArray,activityArray);
        
        % Millerize data
        [millerTime_seconds{i1},millerCs{i1}] = millerize(timeArray(complianceArray),csArray(complianceArray));
        [~,millerActivity{i1}] = millerize(timeArray(complianceArray),activityArray(complianceArray));
    end
    
    % Remove empty cells
    idxEmpty = cellfun(@isempty,millerTime_seconds);
    millerTime_seconds(idxEmpty) = [];
    millerCs(idxEmpty) = [];
    millerActivity(idxEmpty) = [];
    
    % Count subjects
    nSubjects = num2str(numel(millerTime_seconds));
    
    % Millerize combined data
    combinedTime_seconds = cell2mat(millerTime_seconds);
    combinedCs = cell2mat(millerCs);
    combinedActivity = cell2mat(millerActivity);
    [combinedMillerTime_days,combinedMillerCs] = millerize2(combinedTime_seconds,combinedCs);
    [~,combinedMillerActivity] = millerize2(combinedTime_seconds,combinedActivity);
    % Plot data
    hAxes = axes;
    hold on
    hAI = area(combinedMillerTime_days,combinedMillerActivity,'DisplayName','Activity Index (AI)');
    set(hAI,'FaceColor',[0,0,0],'EdgeColor','none');
    hCS = area(combinedMillerTime_days,combinedMillerCs,'DisplayName','Circadian Stimulus (CS)');
    set(hCS,'FaceColor',[0.8,0.8,0.8],'EdgeColor','none');
    set(hAxes,'XTick',xTicks,'YTick',yTicks,'XLim',[0,1],'YLim',[0,.7],'TickDir','out');
    datetick2('x','HH:MM','keeplimits','keepticks');
    legend('show','Location','NorthEast');
    title([displaySeasonCell{i0},': ',nSubjects,' Subjects']);
    hold off
    
    millerPath = fullfile(Paths.plots,['combinedMiller_',runtime,'_GSA_',plainLocation,'-people',plainSeasonCell{i0},'.pdf']);
    print(gcf,'-dpdf',millerPath,'-painters');
    clf
    
    phasorplot(phasorMagnitude,phasorAngleHrs,.6,3,6,'top','left',.1);
    
    title([displaySeasonCell{i0},': ',nSubjects,' Subjects']);
    hold off
    
    compassPath = fullfile(Paths.plots,['combinedCompass_',runtime,'_GSA_',plainLocation,'-people',plainSeasonCell{i0},'.pdf']);
    print(gcf,'-dpdf',compassPath,'-painters');
    clf
end

close all

end


function [phasorMagnitude,phasorAngleHrs] = phasorprep(complianceArray,bedArray,timeArray,csArray,activityArray)
clf;

% replace in bed time
csArray(bedArray) = 0;
activityArray(bedArray) = 0;

% remove only large noncompliance while awake
complianceArray = adjustcrop(timeArray,complianceArray,bedArray);
timeArray(~complianceArray) = [];
csArray(~complianceArray) = [];
activityArray(~complianceArray) = [];

Phasor = phasoranalysis(timeArray,csArray,activityArray);
phasorMagnitude	= Phasor.magnitude;
phasorAngleHrs  = Phasor.angleHrs;

end
