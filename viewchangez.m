function viewchangez(src,event,data) 
nodes=get(data.w,'Nodes');
nodes(1).rotation = [[0 0 1] pi/2]; 
end
