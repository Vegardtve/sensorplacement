function my_visualize_function(src,event,S,data) 

    uiresume(S.d);

    
    figure
    rotate3d on
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    camorbit(0, -90);

data.tp = vrifs2patch(data.w.layout.children.geometry);
    data.tp.FaceColor = 'red';
    hold on

 n = size(S.lines); 
for i = 1:n(1)
    X_start(i,1) = S.lines{i,1}; 
    X_end(i,1) = S.lines{i,2}; 
    Y_start(i,1)	= S.lines{i,3}; 
    Y_end(i,1) = S.lines{i,4}; 
    Z_start(i,1) = S.lines{i,5}; 
    Z_end(i,1) = S.lines{i,6}; 
end

% for i = 1:n(1)
%     X_start(i,1) = S.lines{i,2}; 
%     X_end(i,1) = S.lines{i,3}; 
%     Y_start(i,1)	= S.lines{i,4}; 
%     Y_end(i,1) = S.lines{i,5}; 
%     Z_start(i,1) = S.lines{i,6}; 
%     Z_end(i,1) = S.lines{i,7}; 
% end


X = [X_start' ; X_end']';
Y = [Y_start' ; Y_end']';
Z = [Z_start' ; Z_end']';
for j = 1:length(X)
plot3(X(j,1:2),Y(j,1:2),Z(j,1:2),'b','LineWidth',2)
end

lines = {X,Y,Z}; 

src.UserData = lines; 


end