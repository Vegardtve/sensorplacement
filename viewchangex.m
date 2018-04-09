function viewchangex(src,event,data) 
nodes=get(data.w,'Nodes');
nodes(1).rotation = [[1 0 0] pi/2]; 
data.c.CameraPosition = [35.4241  -40.1108  -26.9312]; 
data.c.CameraDirection = [-0.4467    0.6996    0.5578]; 
data.c.CameraUpVector = [-0.3234   -0.7075    0.6283]; 
end
