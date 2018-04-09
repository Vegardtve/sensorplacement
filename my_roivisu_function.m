function my_roivisu_function(src,event,data) 
uiresume(data.f)

A = load('roi.mat')

figure
camorbit(0, -90);
for i = 1:length(A.roi)
   curr = A.roi{i}
   faces =  curr{2}; 
   vertices = curr{3}; 
   roipatch = patch('Faces',faces,'Vertices',vertices)
   roipatch.FaceAlpha = 0.3; 
   
   hold on
   open(data.w)

   data.tp = vrifs2patch(data.w.layout.children.geometry);
   data.tp.FaceColor = 'red';
end
end
