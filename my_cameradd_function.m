function my_cameradd_function(src,event,data) 
uiresume(data.f)
% Callback function for "Add Camera" (eh2_camera_add)
prompt = {'Field of View [deg]:','Range [m]:', 'Price [-]'};
dlg_title = 'Add Camera';
num_lines = 2;
defaultans = {'120','30','5'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);


fov = str2num(answer{1}); 
r = str2num(answer{2}); 
pr = str2num(answer{3}); 
cam = [fov r pr]; 
src.UserData = cam; 
set(src,'Tag','1')
end