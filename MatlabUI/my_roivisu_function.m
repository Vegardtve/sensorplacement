function my_roivisu_function(src,event,data) 
uiresume(data.f)

A = load('roi.mat')

figure('Name', 'Figure For ROI Visualization','NumberTitle','off');
xlabel('X')
ylabel('Y')
zlabel('Z')
camorbit(0, -90);
for i = 1:length(A.roi)
   curr = A.roi{i}
   faces =  curr{2}; 
   vertices = curr{3}; 
   roipatch = patch('Faces',faces,'Vertices',vertices)
   roipatch.FaceAlpha = 0.7; 
   roipatch.FaceColor = 'blue'; 
   
   hold on
   open(data.w)

   data.tp = vrifs2patch(data.w.layout.children.geometry);
   data.tp.FaceColor = 'red';
end
end
