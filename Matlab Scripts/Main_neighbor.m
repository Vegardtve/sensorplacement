clc; clear

% Initialize problem

ncams = 5; 
yi(1:ncams) = -6; 
func = @(p)objfunc(p,yi,ncams);
% p is array of decision variables

% Determine bounds for each decision variable
lb(1:5) = [0 -pi/4 -pi/4 0 0]; 
ub(1:5) = [pi/2 pi/4 pi/4 pi/2 pi/2];
lb(6:15) = [0 0 0 0 6.5 6.5 8.5 11 0 0]; 
ub(6:15) = [0 0 0 1 8.5 8.5 10.5 13 0 0];

%Initial guess
x0 = [
    0 0 pi/4 pi/4 pi/4 ...
    0 0 0 0 7.5 ...
    7.5 9.5 12 0 0
    ]; 
%% Fmincon
tic
[x,fval,output] = fmincon(func,x0,[],[],[],[],lb,ub);
toc
		
%% Simulated Annealing
tic
options = saoptimset('PlotFcns',{@saplotbestx,...
          @saplotbestf,@saplotx,@saplotf},'Display','iter');
[x,fval,output] = simulannealbnd(func,x0,lb,ub,options)
toc
%% Global Search
tic
gs = GlobalSearch('Display','iter','StartPointsToRun','bounds'); 
problem = createOptimProblem('fmincon','x0',x0,'objective',func,'lb',lb,...
    'ub',ub);

x = run(gs,problem);
toc
%% Particle Swarm Optimization
tic
nvars = 15; 
options = optimoptions('particleswarm','Display','iter')
[x,fval,exitflag,output] = particleswarm(func,nvars,lb,ub,options)
toc
