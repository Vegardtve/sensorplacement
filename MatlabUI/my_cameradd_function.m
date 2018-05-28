function my_cameradd_function(src,event,data) 
uiresume(data.f)
% Callback function for "Add Camera" (eh2_camera_add)
prompt = {'Field of View [deg]:','Range [length unit]:', 'Price [-]'};
dlg_title = 'Add Camera';
dims = [1 50];
defaultans = {'120','30','5'};
answer = inputdlg(prompt,dlg_title,dims,defaultans);


fov = str2num(answer{1}); 
r = str2num(answer{2}); 
pr = str2num(answer{3}); 
cam = [fov r pr]; 
src.UserData = cam; 
set(src,'Tag','1')
end