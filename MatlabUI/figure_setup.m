% Get the current screensize so that the figure window scales according to 
% the size of the monitor
S=get(0,'ScreenSize');



% Data - Struct where all variables are stored 

% Initialize GUI Figure (VRML Canvas)
data.f = figure('name','Sensor Placement Optimization',...
                'NumberTitle','off');
data.f.ToolBar='auto';                  
data.f.MenuBar = 'none';               
data.f.Position = [S(1) S(2) S(3)-100 S(4)-100]; %[100 0 800 800]; 