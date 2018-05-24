
% Open the *.wrl file and show it in the GUI figure using a Canvas. 
data.w=vrworld('Layout_background.wrl');
open(data.w);
canvas_margin=100;
data.c=vr.canvas(data.w,data.f,[120 0 S(3)-canvas_margin S(4) - canvas_margin]); 
data.c.NavPanel = 'translucent';
data.c.NavZones = 'off';
data.c.Tooltips = 'off'; 
data.c.Triad = 'bottomleft'; 


% Change the objects rotation and translation if desirable
% Set the camera position 
nodes=get(data.w,'Nodes');
nodes(1).translation=[0 0 0];
data.c.CameraPosition = [1.5632 -32.1230 50.8914]; 
data.c.CameraDirection = [0.0178 0.6881 -0.7255]; 
data.c.CameraUpVector = [-0.3768 0.8138 -0.4422]; 
data.editvrml = 0; 
data.A = 'Layout_background.wrl'; 
