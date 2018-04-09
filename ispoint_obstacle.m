function ispoint_obstacle(src,event,data)
uiresume(data.f);

in = load('fishnet.mat');
c = in.c;
bOK = 1; 
prev = 1;
curr = 5;
ystart = 0; 
yprec = 10; 
yend = -6; 
cpy = linspace(ystart,yend,yprec); 
i = 1; 
l = length(c)
while(bOK) 
    out(i) = {c(1:2,prev:curr)}; 
    
    i = i+1; 
    prev = prev+5; 
    curr = curr + 5; 
    
    
    if curr >= l
        bOK = 0; 
    end
end


out_num = length(out); 
ly = length(cpy); 
cppx = [0]; cppy = [0]; cppz = [0]; 
for j = 1:out_num
    curr_s = out{j};
    cp(j,1:2) = [curr_s(1,1) + (curr_s(1,2)-curr_s(1,1))/2,...
                curr_s(2,1) + (curr_s(2,3)-curr_s(2,2))/2]; 
    for u = 1:ly
    cpxyz(u,1:2) = cp(j,1:2);
    end
    cpxyz(1:ly,3) = cpy;
    cppx = [cppx cpxyz(1:ly,1)'];
    cppy = [cppy cpxyz(1:ly,2)'];
    cppz = [cppz cpxyz(1:ly,3)'];
end
open(data.w)
figure
pat = vrifs2patch(data.w.layout.children.geometry);
pat.FaceColor = 'red';

lcppx = length(cppx); 
qp = [cppx; cppz; cppy]';
fv.faces = pat.Faces; 
fv.vertices = pat.Vertices; 

t = inpolyhedron(fv,qp);
% in = intriangulation(vertices,faces,qp)
a = find(t==1);
annot(1:lcppx) = 0; 
for x = 1:length(a)
    ind = a(x);
    annot(ind) = 1; 
end

src.UserData = annot; 

end

