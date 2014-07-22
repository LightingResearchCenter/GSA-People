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


function [bedTimeArray, riseTimeArray] = importbedlog(file)
% imports the bed log given by file.
[~, ~, ext] = fileparts(file);
switch ext
    case '.m'
        load(file);
    case {'.xls','.xlsx'}
        % Import bed log as a table
        [~,~,bedLogCell] = xlsread(file);
        
        % Initialize the arrays
        nIntervals = length(bedLogCell)-1;
        bedTimeArray = zeros(nIntervals,1);
        riseTimeArray = zeros(nIntervals,1);
        
        % Load the data from the cell
        for i1 = 1:length(bedTimeArray)
            bedTimeArray(i1) = datenum(bedLogCell{i1 + 1,2});
            riseTimeArray(i1) = datenum(bedLogCell{i1 + 1,3});
        end
    case '.txt'
        fileID = fopen(file);
        [bedCell] = textscan(fileID,'%f%s%s%s%s','headerlines',1);
        bedd = bedCell{2};
        bedt = bedCell{3};
        rised = bedCell{4};
        riset = bedCell{5};
        bedTimeArray = zeros(size(bedd));
        riseTimeArray = zeros(size(bedd));
        % this can probably be vectorized
        for i1 = 1:length(bedd)
            bedTimeArray(i1) = datenum([bedd{i1} ' ' bedt{i1}]);
            riseTimeArray(i1) = datenum([rised{i1} ' ' riset{i1}]);
        end
        fclose(fileID);
    otherwise
        return
end

end