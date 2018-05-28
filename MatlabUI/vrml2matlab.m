%% VR -> Matlab
clear; 
close all; 
w1 = vrworld('Layout_simple1.wrl'); 
open(w1); 

vrfig1 = vrfigure(w1, ...
           'Name', 'Virtual world containing source IndexedFaceSet node', ...
           'CameraBound', 'off', ...
           'CameraPosition',[0 40 0], ...
           'CameraDirection',[0 -1 0], ...
           'CameraUpVector',[0 0 -1]);
vrdrawnow;

figure('Name', 'Resulting patch','NumberTitle','off');
tp = vrifs2patch(w1.layout.children.geometry);
tp.FaceColor = 'red';

axs = gca;
axs.XGrid = 'on';
axs.YGrid = 'on';
axs.ZGrid = 'on';
xlabel('X')
ylabel('Y')
zlabel('Z')
ylim([-10 0])
camorbit(370, -95);

rotate3d on

% Floor Generation (Layout.wrl)
% clear; 
% close all
x = [0 18.01 18 14.51 0.01]; 
y = [0 0 0 0 0]; 
z = [0 0 5 2.5 24]; 
% figure
% P = patch('Xdata',x,'Ydata',y,'ZData',z)
P = patch(x,y,z,'b')
rotate3d('on')
% figure; 
% fill3

vrpatch2ifs(P,w1); 
vrfig2 = vrfigure(w1)

get(w1)
