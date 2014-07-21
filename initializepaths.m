function Paths = initializepaths(project,session)
%INITIALIZEPATHS Prepare GSA folder and file paths
%   Detailed explanation goes here

% Preallocate output structure
Paths = struct(...
    'Dir',  struct(...
            'gsa'           ,'',...
            'project'       ,'',...
            'originalData'  ,'',...
            'editedData'    ,'',...
            'results'       ,'',...
            'plots'         ,'',...
            'logs'          ,''),...
    'File', struct(...
            'index'         ,'',...
            'bedLog'        ,'',...
            'cropLog'       ,''));

% Retain only alphabetic characters from input and convert to lowercase
project = lower(regexprep(project,'\W',''));
session = lower(regexprep(session,'\W',''));

% Set GSA parent directory
Paths.Dir.gsa = fullfile([filesep,filesep],'root','projects','GSA_Daysimeter');
% Check that it exists
if exist(Paths.Dir.gsa,'dir') ~= 7 % 7 = folder
    error(['Cannot locate the folder: ',Paths.Dir.gsa]);
end

% Specify project directory
switch project
    case {'grandjunction','colorado','co'}
        Paths.Dir.project = fullfile(Paths.Dir.gsa,...
            'GrandJunction_Colorado_site_data','Daysimeter_People_Data');
    case {'portland','oregon','or'}
        Paths.Dir.project = fullfile(Paths.Dir.gsa,...
            'Portland_Oregon_site_data','Daysimeter_People_Data');
    otherwise
        error('Unknown project.');
end

% Specify session specific directories
Paths.Dir.originalData = fullfile(Paths.Dir.project,[session,'OriginalData']);
Paths.Dir.editedData   = fullfile(Paths.Dir.project,[session,'EditedData']);
Paths.Dir.results      = fullfile(Paths.Dir.project,[session,'Results']);
Paths.Dir.plots        = fullfile(Paths.Dir.project,[session,'Plots']);
Paths.Dir.logs         = fullfile(Paths.Dir.project,[session,'Logs']);

% Specify files
Paths.File.index   = fullfile(Paths.Dir.logs,'index.xlsx');
Paths.File.bedLog  = fullfile(Paths.Dir.logs,'bedLog.xlsx');
Paths.File.cropLog = fullfile(Paths.Dir.logs,'cropLog.xlsx');

end

