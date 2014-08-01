function prelimdaysigrams
%PRELIMDAYSIGRAMS Summary of this function goes here
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% Have user select project location and session
location = gui_locationselect;
session  = gui_sessionselect;

% Construct paths
Paths = initializepaths(location,session);
[~,filePathArray] = searchdir(Paths.originalData,'cdf');

for i1 = 1:numel(filePathArray)
    Data = ProcessCDF(filePathArray{i1});
    
    sheetTitle  = ['Subject: ',Data.GlobalAttributes.subjectID{1},' preliminary'];
    fileID      = ['preliminaryDaysigram_subject',Data.GlobalAttributes.subjectID{1}];
    
    generatereport(sheetTitle,Data.Variables.time,Data.Variables.activity,...
        Data.Variables.CS,'cs',[0,1],14,Paths.plots,fileID);
end

end

