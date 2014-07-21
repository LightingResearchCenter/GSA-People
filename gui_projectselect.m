function project = gui_projectselect
%GUI_PROJECTSELECT GUI to select the desired project
%   Detailed explanation goes here

choice = menu('Choose a project location',...
    'Grand Junction, CO',...
    'Portland, OR');

projectArray = {'grandjunction','portland'};

project = projectArray{choice};

end

