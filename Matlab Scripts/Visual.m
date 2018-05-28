%% Program to Evaluate Fitness of a Sensor Combination 
clear; 
clc; 
close all; 
env = environment_generate('mini_0705.mat');  
datax = env.datax;                          % Discrete data points (x)
datay = env.datay;                          % Discrete data points (y)
dataz = env.dataz;                          % Discrete data points (z)
campx = env.campx;                          % Discrete placement points (x)
campy = env.campy;                          % Discrete placement points (y)
campz = env.campz;                          % Discrete placement points (z)
obsta = env.obsta;
annot = env.annot; 

% Preallocate variables and initialize
ldata = length(datax);                      % Number of data points
ncams = 5;
c = 0; 
% Determine initial coverage array
for i = 1:ldata
    if(annot(i) == 2)
        init_cov(i) = 2; 
        c = c + 1; 
    else 
        init_cov(i) = 1; 
    end
end
b = false(ncams,ldata);                     % Coverage matrix - Combs
iter = 0;  
p = [0.0264   -0.0296    0.7689    0.8033    0.8050];   %Pan
x = [0         0         0    0.2426    7.7448];        % X Pos
z = [7.9870    9.6687   12.2536 0 0];                   % Z Pos

y(1:ncams) = -6;

% Compute coverage for all possible camera poses and positions
for i = 1:ncams    
    pan = p(i);
        % Compute coverage of all data points 
        for n = 1:ldata
            b(i,n) = covered1(n,x(i),y(i),z(i),datax,datay,dataz,...
                                obsta,pan);
        end   
end
cove = zeros(1,ldata);
out = zeros(1,ldata); 
cf = 0; 
totsum = 0; 
% Evaluate visibility and coverage from all sensors
for j = 1:ncams
    for i = 1:ldata
        if( b(j,i) )
            cove(i) = cove(i) + 1; 
        end
    end
end
% Evaluation k-coverage 
for k = 1:ldata
    if(cove(k) >= init_cov(k))
        totsum = totsum + 1; 
        out(k) = 1; 
        if(init_cov(k) == 2)
            cf = cf + 1; 
        end
    end
end
tot = totsum;
% Figure for visualization
figure()
ccc = 0; 
for i = 1:ldata
    if(annot(i) == 2 && out(i) == 1) 
        scatter3(datax(i),dataz(i),datay(i),'b');
        hold on
    end
    if(annot(i) == 2 && out(i) == 0)
        scatter3(datax(i),dataz(i),datay(i),'r');
        hold on
    end
    if out(i) == 0
        ccc = ccc + 1; 
        scatter3(datax(i), dataz(i), datay(i),'m')
        hold on 
    end
end
for(k = 1:length(campx))
    scatter3(campx(k),campy(k),campz(k),'g*')
    hold on
end
for j = 1:ncams
    scatter3(x(j), y(j), z(j),'k')
    hold on
    
end
for i = 1:length(obsta)
    scatter3(obsta(i,1), obsta(i,3), obsta(i,2),'r*')
    hold on 
end
h = zeros(5, 1);
h(1) = plot(NaN,NaN,'ob');
h(2) = plot(NaN,NaN,'ok');
h(3) = plot(NaN,NaN,'*g');
h(4) = plot(NaN,NaN,'*r');
h(5) = plot(NaN,NaN,'om');
legend(h, 'ROI','Camera positions','Possible placement points',...
        'Obstacles','Uncovered data points');
title('Coverage Results'); 
xlabel('X [m]')
ylabel('Y [m]')
zlabel('Z [m]')

fprintf('The sum is %i \n',tot)
if cf < c
    fprintf('The ROI is not fully covered\n')
else
    fprintf('The ROI is fully covered\n')
end

disp(tot/9084)