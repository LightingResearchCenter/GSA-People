function Paths = initializepaths(location,session)
%INITIALIZEPATHS Prepare GSA folder and file paths
%   Detailed explanation goes here

% Preallocate output structure
Paths = struct(...
    'gsa'           ,'',...
    'location'      ,'',...
    'originalData'  ,'',...
    'editedData'    ,'',...
    'results'       ,'',...
    'plots'         ,'',...
    'logs'          ,'');

% Retain only alphabetic characters from input and convert to lowercase
location = lower(regexprep(location,'\W',''));
session  = lower(regexprep(session,'\W',''));

% Set GSA parent directory
Paths.gsa = fullfile([filesep,filesep],'root','projects','GSA_Daysimeter');
% Check that it exists
if exist(Paths.gsa,'dir') ~= 7 % 7 = folder
    error(['Cannot locate the folder: ',Paths.gsa]);
end

% Specify location directory
switch location
    case {'grandjunction','colorado','co'}
        Paths.location = fullfile(Paths.gsa,...
            'GrandJunction_Colorado_site_data','Daysimeter_People_Data');
    case {'portland','oregon','or'}
        Paths.location = fullfile(Paths.gsa,...
            'Portland_Oregon_site_data','Daysimeter_People_Data');
    otherwise
        error('Unknown project.');
end

% Specify session specific directories
Paths.originalData = fullfile(Paths.location,[session,'OriginalData']);
Paths.editedData   = fullfile(Paths.location,[session,'EditedData']);
Paths.results      = fullfile(Paths.location,[session,'Results']);
Paths.plots        = fullfile(Paths.location,[session,'Plots']);
Paths.logs         = fullfile(Paths.location,[session,'Logs']);

end

