function viewchangey(src,event,data) 
nodes=get(data.w,'Nodes');
nodes(1).rotation = [[0 1 0] pi/2]; 
end
