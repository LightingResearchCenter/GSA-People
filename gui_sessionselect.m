function session = gui_sessionselect
%GUI_SESSIONSELECT GUI to select desired session
%   Detailed explanation goes here

choice = menu('Choose a project session',...
    'Summer',...
    'Winter');

sessionArray = {'summer','winter'};

session = sessionArray{choice};

end

