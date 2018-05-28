function my_roiadd_function(src,event,data) 

    uiresume(data.f);
% Cellular display of floor object, swipe along horizontal axis
% Input Vectors: x,y
% Input : n - Discretization size
%         nlim - Linspace number
% Initialize
c = load('corners.mat'); 
x = c.corners(1,1:end); 
y = c.corners(2,1:end); 
z = c.corners(3,1:end); 
xl = []; 
yl = []; 

% figure
% rotate3d on

area = polyarea(x,z); 
% Patch object 
nlin = 400; 
ncubes = 150; 
roi = load('roi_setup.mat');

% For loop to linearly space line between all corners
for j = 1:length(x) 
    if j == length(x) % If last element, connect with first
        if x(j) == x(1) % If last element equals first element
            x_l(j,1:nlin) = x(j);
            y_l(j,1:nlin) = linspace(z(j),z(1),nlin); 
        else    % Else connect with first element
%             xd = x(i) + x(1); zd = z(i) + z(1); 
            m = (z(j) - z(1))/(x(j) - x(1)); 
            x_l(j,1:nlin) = linspace(x(j),x(1),nlin); 
            y_l(j,1:nlin) = m*x_l(j,1:nlin) - m*x(j) + z(j); 
        end
    else % Connect currenet corner with next corner
%     xd = x(i) + x(i+1); zd = z(i) + z(i+1); 
    m = (z(j) - z(j+1))/(x(j) - x(j+1)); 
    x_l(j,1:nlin) = linspace(x(j),x(j+1),nlin);
    y_l(j,1:nlin) = m*x_l(j,1:nlin) - m*x(j) + z(j); 
    end  % Make a row vector of all data points
    xl = [xl x_l(j,1:nlin)];
    yl = [yl y_l(j,1:nlin)];
end    
x_l = xl; 
y_l = yl; 

% Visualization : Plot data points on top of original data
% figure
% p = patch(x,y,z,'r');
figure('Name', 'Figure For Adding ROI','NumberTitle','off');
scatter(x_l,y_l)
hold on
scatter(x,z,'r')
xlabel('X')
ylabel('Z')



% Generate fishnet
sq_area = area/ncubes; 
side = 0.5; 
% Initialize data for fishnet generation
i = 1; 
origin = [0 ;0];
L = origin;

if roi.roidata.sw_dir(1) == 1
   
x_2 = round(x_l,1);
xlim = max(x_l);

bOK = true;
while(bOK) 
    % Determine corner coordinates of current rectangle
    L = [origin(1) ;origin(2)+side]; 
    B = [origin(1) + side ;origin(2)];
    R = [origin(1) + side ;origin(2) + side]; 
    L_2 = round(R(1),1); 
        if L_2 >= xlim
        break 
    end
    
    
    x_current = find(x_2==L_2);

    y_vals = y_l(x_current); 
    ylim = max(y_vals);

    if R(1) <= xlim % If current x value < maximum x value
        
        if L(2) <= ylim  % If current y value < max y -> make next rectangle
                        % On top of previous     
            cubes{i} = [origin B R L origin];
            curr_cube = cubes{i};
            hold on;    % Plot for visualization
            plot(curr_cube(1,1:end),curr_cube(2,1:end),'k') 
            origin = [L(1) ;L(2)];
            i = i + 1; 
        else
            % If current y value >= max y -> move next rectangle down 
            % to the bottom of the next column on the right
            cubes{i} = [origin B R L origin];
            curr_cube = cubes{i};
            hold on     % Plot for visualization
            plot(curr_cube(1,1:end),curr_cube(2,1:end),'k')  
            origin = [B(1) ;0];
            i = i + 1;         
        end
    else  % Close loop
        bOK = 0; 
    end
    pause(0.03) % Pause for visualization purposes
end
else
   
y_2 = round(y_l,1);
ylim = max(y_l);
  

bOK = true;
while(bOK) 
    % Determine corner coordinates of current rectangle
    L = [origin(1) ;origin(2)+side]; 
    B = [origin(1) + side ;origin(2)];
    R = [origin(1) + side ;origin(2) + side]; 
    L_2 = round(R(2),1); 
    if L_2 >= ylim
        break 
    end
    y_current = find(y_2==L_2);
    for i = 1:length(y_current) % Determine maximum x-value for current y
        x_vals = x_l(y_current); 
        xlim = max(x_vals);
    end
    if L(2) <= ylim % If current y value < maximum x value
        
        if R(1) <= xlim  % If current x value < max x -> make next rectangle
                        % On top of previous
            cubes{i} = [origin B R L origin];
            curr_cube = cubes{i};
            hold on;    % Plot for visualization
            plot(curr_cube(1,1:end),curr_cube(2,1:end),'k') 
            origin = [B(1) ;B(2)];
            i = i + 1; 
        else
            % If current x value >= max x -> move next rectangle down 
            % to the bottom of the next column on the right
            cubes{i} = [origin B R L origin];
            curr_cube = cubes{i};
            hold on     % Plot for visualization
            plot(curr_cube(1,1:end),curr_cube(2,1:end),'k')  
        
            origin = [0 ; L(2)];
            i = i + 1;         
        end
    else  % Close loop
        bOK = 0; 
    end
     pause(0.03)
end
end
prompt = {'Weight:','UL:', 'UR','BL','BR','Ymin','Ymax'};
dlg_title = 'Specify ROI';
num_lines = 1;
defaultans = {'1','2.847 9.489','6.643 9.489','2.847 6.643',...
              '6.643 6.643','-2','-4'};
options.Resize = 'on'; 
options.WindowStyle = 'normal'; 
answer = inputdlg(prompt,dlg_title,num_lines,defaultans,options);


w = str2num(answer{1}); 
UL = str2num(answer{2}); 
UR = str2num(answer{3}); 
BL = str2num(answer{4}); 
BR = str2num(answer{5}); 
Y0 = str2num(answer{6}); 
Y1 = str2num(answer{7}); 

vertices = [BL(1) Y0 BL(2); BR(1) Y0 BR(2); UR(1) Y0 UR(2);...
            UL(1) Y0 UR(2); BL(1) Y1 BL(2); BR(1) Y1 BR(2);...
            UR(1) Y1 UR(2); UL(1) Y1 UL(2)];
faces = [1 2 6 5; 1 2 3 4; 1 4 8 5; 2 3 7 6; 4 3 7 8; 5 6 7 8];

roidata = [w, UL, UR, BL, BR, Y0, Y1]; 
set(src,'Tag','1');
src.UserData = {i, faces,vertices,roidata};
setappdata(src,'cubes',cubes); 

end
