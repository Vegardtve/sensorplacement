function my_setuppara_function(src,event,data)
uiresume(data.f);

% Load grid data
in = load('fishnet.mat');
c = in.c;                    % Extract fishnet squares

% Optimization Setup Data
Aa = load('Optimsetup.mat'); 
setpara = Aa.optsetup;       % Extract user-defined optimization parameters


% Initialize parameters
bOK = 1;    
prev = 1;
curr = 5;
i = 1; 
l = length(c);

% User input optimization parameters
ystart = setpara(1);        % Height at floor level
yprec = setpara(3);         % Discretization points between bottom and top 
yend = setpara(2);          % Heigth at top level


% Make array of linearly spaced points between floor and top level
cpy = linspace(ystart,yend,yprec); 


% Determine number of squares (each square has 5 data points)
while(bOK) 
    out(i) = {c(1:2,prev:curr)};    % Struct array of square coordinates
    
    i = i+1;                        % Square counter
    prev = prev+5;                  
    curr = curr + 5; 
    
    % If curr >= length of grid array
    if curr >= l
        bOK = 0; 
    end
end

% Loop to determine cubes center points
out_num = length(out);                   % Number of cubes
ly = length(cpy);                        % Number of discrete height points

% Initialization
cppx = []; cppy = []; cppz = [];         
cp(1:out_num,1:2) = 0; 

% For each square
for j = 1:out_num
    curr_s = out{j};        % Current cube
    % Determine mid-point
    cp(j,1:2) = [curr_s(1,1) + (curr_s(1,2)-curr_s(1,1))/2,...
                curr_s(2,1) + (curr_s(2,3)-curr_s(2,2))/2];  
    % Add height coordinates for each mid-point
    for u = 1:ly
    cpxyz(u,1:2) = cp(j,1:2);
    end
    cpxyz(1:ly,3) = cpy;
    
    % Collect all data points in arrays of x, y and z coordinates
    cppx = [cppx cpxyz(1:ly,1)'];
    cppy = [cppy cpxyz(1:ly,2)'];
    cppz = [cppz cpxyz(1:ly,3)'];
end

% Compute points inside input indexed face set

lcppx = length(cppx);                   % Number of data points
qp = [cppx; cppz; cppy]';               % Matrix of data points

% Import scene model
open(data.w)
% figure
pat = vrifs2patch(data.w.layout.children.geometry);
pat.FaceColor = 'red';
fv.faces = pat.Faces; 
fv.vertices = pat.Vertices; 


% Function Copyright...
% Determine indeces of points inside "obstacles" defined by input scene
t = inpolyhedron(fv,qp,'tol');

% Compute points inside region of interest


% Load ROI Data
inp = load('roi.mat');      % User-defined Region of Interest(ROI) data 
nroi = length(inp.roi);     % Number of ROIs
annot(1:lcppx) = 0;         % Initialize annotation array

% Open figure for visualization
% figure
% rotate3d on

% For each region of interest
for p = 1:nroi
roi_in = inp.roi{p};        % Extract current ROI
coords = roi_in{4};         % Extract user-defined ROI coordinates
w = coords(1);              % ROI weight
UL = coords(2:3);           % Upper left corner (x,z)
UR = coords(4:5);           % Upper right corner (x,z)
BL = coords(6:7);           % Bottom left corner (x,z)
BR = coords(8:9);           % Bottom right corner (x,z)
Y0 = coords(10);            % Heigth at bottom of ROI (y)
Y1 = coords(11);            % Heigth at top of ROI (y)

% Make triangulated patch object of ROI
vertices = [BL(1) Y0 BL(2); BR(1) Y0 BR(2); UR(1) Y0 UR(2);...
            UL(1) Y0 UL(2); BL(1) Y1 BL(2); BR(1) Y1 BR(2);...
            UR(1) Y1 UR(2); UL(1) Y1 UL(2)];
        

faces = [1 6 2; 1 5 6; 2 6 7; 2 7 3; 5 8 7; 5 7 6; 1 3 2;...
         1 4 3; 4 7 3; 4 8 7; 1 8 4; 1 5 8]; 
% Make object of faces and vertices
fvroi.faces =faces; 
fvroi.vertices = vertices; 
% Ensure that all face normals points in the same direction
fvroi.faces = unifyMeshNormals(fvroi.faces,fvroi.vertices); 
% Determine data points inside ROIs
t_roi = inpolyhedron(fvroi,qp,'flipNormal',true);

% Plotting for visualization

patt = patch('Faces',fvroi.faces,'Vertices',fvroi.vertices);
patt.FaceAlpha = 0.3;

% Annotate data points
% 1 -  Obstacle
% 0 -  1 coverage (standard)
% Annotation according to weigth of ROI
% 4 - No interest
% 2 - 2 covered
% 3 - 3 covered

% Find indexes of roi points
a_roi = find(t_roi==1);

% For all points inside roi annotate accordingly
for x = 1:length(a_roi)
    ind_roi = a_roi(x);     % Get index
    if w==1
        annot(ind_roi) = 2;     % Annotate point
    elseif w==2 
        annot(ind_roi) = 3; 
    elseif w==3 
        annot(ind_roi) = 4; 
    end
end

end

% Find indexes of obstacle points
a = find(t==1);

% For all points inside obstacle annotate accordingly
for x = 1:length(a)
    ind = a(x);             % Get index
    annot(ind) = 1;         % Annotate point
end





% Camera Positions
cl = load('lines.mat');               % Load user-defined placement lines
camf = cl.save_lines;                 % Extract data
nc = size(camf);                      % Get number of lines
numc = nc(1);               
pl_accuracy = setpara(4);             % Extract user defined accuracy

xcam = [];                            % Initialize array
zcam = [];                            % Initialize array

% For each placement lines
for u = 1:numc
    % Get start and end coordinates
    xs = camf{u,2};             % Start coordinate (x)                  
    xe = camf{u,3};             % End coordinate (x)
    zs = camf{u,6};             % Start coordinate (z)
    ze = camf{u,7};             % End coordinate (z)
      
    len = sqrt((xe-xs)^2+(ze-zs)^2);    % Compute length of line 
    % If vertical line discretize along z
    if xs == xe                         
        zlin = linspace(zs,ze,pl_accuracy*(len+1)); % Linspace along z
        xlin(1:length(zlin)) = xe;                  % All x points equal
    % Else discretize using 2-point eq.
    else                                
        m = (zs - ze)/(xs - xe);                    % Line gradient
        xlin = linspace(xs,xe,pl_accuracy*(len+1)); % Linspace along x
        zlin = m*xlin - m*xs + zs;             % Corresponding z for all x
    end
    % Collect discrete placement points for all lines
    xcam = [xcam xlin]; 
    zcam = [zcam zlin]; 
end    
% Plottig for visualization
f = figure('Name','Visualize Optimization','NumberTitle','off');
xlabel('X')
ylabel('Y')
zlabel('Z')

rotate3d on
view(22,12)
% Plotting for visualization
for i = 1:lcppx        
   hold on
   if annot(i) == 2
       scatter3(cppx(i),cppz(i),cppy(i),'r')
   elseif annot(i) == 1
       scatter3(cppx(i),cppz(i),cppy(i),'k')
   elseif annot(i) == 3 
       scatter3(cppx(i),cppz(i),cppy(i),'g')
   elseif annot(i) == 4
       scatter3(cppx(i),cppz(i),cppy(i),'m')
   else
       scatter3(cppx(i),cppz(i),cppy(i),'b')
   end
end

ycam(1:length(xcam)) = yend;      
hold on
scatter3(xcam,ycam,zcam,'*r')
hold on
h = zeros(6, 1);
h(1) = plot(NaN,NaN,'or');
h(2) = plot(NaN,NaN,'ob');
h(3) = plot(NaN,NaN,'ok');
h(4) = plot(NaN,NaN,'og');
h(5) = plot(NaN,NaN,'om');
h(6) = plot(NaN,NaN,'*r'); 
legend(h,'2-coverage ROI','1-coverage (Standard)','Obstacle',...
     '4-coverage ROI','Non Interest ROI','Location','NorthEastOutside',...
     'Camera Position');

    

    
% hold on
% scatter3(xcam,ycam,zcam,'*r')


% Output data
 
set(src,'Tag','1'); 
src.UserData = {annot,xcam,zcam,cppx,cppy,cppz}; 

end