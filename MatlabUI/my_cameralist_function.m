function my_cameralist_function(src,event,data) 
% Callback function for "List of Added Cameras" (eh2_camera_visu)
% Resume - respond to uiwait in while loop
uiresume(data.f)

% Load file of added cameras
matfile = load('added_camera.mat'); 
camdata = matfile.cam; 
s = size(camdata); 
n = s(1); 

for i = 1:n
    tabdata{i,1} = camdata(i,1); 
    tabdata{i,2} = camdata(i,2); 
    tabdata{i,3} = camdata(i,3); 
end

% Dialog box with added cameras
S.d = dialog('Position',[200 50 500 400],'Name',...
    'List of Added Cameras',...
    'WindowStyle','normal');
t = uitable(S.d,'Data',tabdata,'Position',[50 50 400 300]);   
t.ColumnName = {'Field of View','Range',...
                'Price'};
t.ColumnEditable = true;        % Make table elements editable

% 
cam = t.Data; 
src.UserData = cam; 
set(src,'Tag','1')
end