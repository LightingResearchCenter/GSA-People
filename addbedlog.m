function addbedlog
%ADDBEDLOG Add bed logs to data that is already cropped
%   Detailed explanation goes here

% Enable dependecies
initializedependencies;

% Have user select project location and session
location = gui_locationselect;
session  = gui_sessionselect;

% Construct project paths
Paths = initializepaths(location,session);
[~,cdfPathArray] = searchdir(Paths.editedData,'cdf');
[bedLogFileNameArray,bedLogPathArray] = searchdir(Paths.logs,'xlsx');

% Extract subject from bed logs
bedSubject = str2double(regexprep(bedLogFileNameArray,'.*(\d\d).*','$1'));

for i1 = 1:numel(cdfPathArray)
    Data = ProcessCDF(cdfPathArray{i1});
    
    subject = str2double(Data.GlobalAttributes.subjectID{1});
    bedIdx = bedSubject == subject;
    
    [bedTimeArray,riseTimeArray] = importbedlog(bedLogPathArray{bedIdx});
    
    bedArray = false(size(Data.Variables.time));
    for i2 = 1:length(bedTimeArray)
        temp = Data.Variables.time > bedTimeArray(i2) & ...
               Data.Variables.time < riseTimeArray(i2);
        bedArray = bedArray | temp;
    end
    Data.Variables.bedArray = bedArray;
    
    % Bed array properties
    Data.VariableAttributes.description{12,1} = 'bedArray';
    Data.VariableAttributes.description{12,2} = 'bed array, true = subject reported being in bed';
    Data.VariableAttributes.unitPrefix{12,1} = 'bedLog';
    Data.VariableAttributes.unitPrefix{12,2} = '';
    Data.VariableAttributes.baseUnit{12,1} = 'bedLog';
    Data.VariableAttributes.baseUnit{12,2} = '1';
    Data.VariableAttributes.unitType{12,1} = 'bedArray';
    Data.VariableAttributes.unitType{12,2} = 'logical';
    Data.VariableAttributes.otherAttributes{12,1} = 'bedArray';
    Data.VariableAttributes.otherAttributes{12,2} = '';
    
    % Rewrite file
    delete(cdfPathArray{i1});
    RewriteCDF(Data,cdfPathArray{i1});
end


end

