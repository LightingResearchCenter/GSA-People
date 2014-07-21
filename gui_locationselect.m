function location = gui_locationselect
%GUI_LOCATIONSELECT GUI to select the desired project
%   Detailed explanation goes here

choice = menu('Choose a project location',...
    'Grand Junction, CO',...
    'Portland, OR');

locationArray = {'grandjunction','portland'};

location = locationArray{choice};

end

