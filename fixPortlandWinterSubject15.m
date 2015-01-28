clear
clc

initializedependencies;

Paths = initializepaths('portland','winter');

file = fullfile(Paths.originalData,'0133-2014-12-12-16-33-18.cdf');
Data = ProcessCDF(file);
Data.GlobalAttributes.subjectID{1} = '15';
delete(file);
RewriteCDF(Data, file);

file = fullfile(Paths.editedData,'0133-2014-12-12-16-33-18.cdf');
Data = ProcessCDF(file);
Data.GlobalAttributes.subjectID{1} = '15';
delete(file);
RewriteCDF(Data, file);