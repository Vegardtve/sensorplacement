%% Genetic Algorithm with K-Coverage
% Author: Vegard Tveit
% Date: 22.05.2018
clear; 
clc; 
close all; 

% Specify the input *.mat file from the UI to set up the environment
env = environment_generate('Final_0705.mat');  
datax = env.datax;                          % Discrete data points (x)
datay = env.datay;                          % Discrete data points (y)
dataz = env.dataz;                          % Discrete data points (z)
campx = env.campx;                          % Discrete placement points (x)
campy = env.campy;                          % Discrete placement points (y)
campz = env.campz;                          % Discrete placement points (z)
obsta = env.obsta;
annot = env.annot; 
% Define number of pan angles
pans = [pi/4,pi/2,-3*pi/4,0]; 

% Preallocate variables and initialize
ldata = length(datax);                      % Number of data points
lpans = length(pans);                       % Number of pan angles
lcamp = length(campx);                      % Number of placement points

x = zeros(lcamp,1);                         % Placement point array (x)
y = zeros(lcamp,1);                         % Placement point array (y)
z = zeros(lcamp,1);                         % Placement point array (x)
b = false(lpans,ldata);                     % Coverage matrix - Combs
iter = 0;      

% Indexation counter
c = 0;
for i = 1:ldata
    if(annot(i) == 2)
        init_cov(i) = 2; 
        c = c + 1; 
    else 
        init_cov(i) = 1; 
    end
end

% Compute coverage for all possible camera poses and positions
for i = 1:lcamp
    x(i) = campx(i);                        % Get camera position (x)
    y(i) = campy(i);                        % Get camera position (y)
    z(i) = campz(i);                        % Get camera position (z)
    
    % Loop through all pan angles
    for k = 1:lpans
        pan = pans(k);                      % Get pan angle
        iter = iter + 1;                    % Update indexation
        
        % Compute coverage of all data points 
        for n = 1:ldata
            b(iter,n) = covered1(n,x(i),y(i),z(i),datax,datay,dataz,...
                                obsta,pan);
        end
    end
end

% Initalize pool of chromosomes randomly
numchromo = 3000; 
numsubs = iter; 
usize = ldata; 
numsens = 3; 
chromo = zeros(numchromo,numsens); 
alpha = 4000; 
for i = 1:numchromo 
    for j = 1:numsens 
        ind = randi(numsubs,1);                     
        chromo(i,j) = ind;
    end
end

b = b'; 
% Evaluate fitness of chromosomes
fitmat = zeros(numchromo,1); 
cove = zeros(1,ldata);
cove(1:end) = init_cov(1:end);
cf = 0; 
for m = 1:numchromo
    bch = false(usize,1); 
    cove = zeros(1,ldata);
    cove(1:end) = init_cov(1:end);
    cf = 0; 
    penalty = 0; 
     barr = zeros(1,ldata); 
    for n = 1:numsens 
        inde = chromo(m,n);        
        for i = 1:ldata
            if( b(i,inde))
                barr(i) = barr(i) + 1; 
            end                                
        end
    end
    for j = 1:ldata
        if(barr(j) >= init_cov(j))
            bch(j) = true; 
            if(annot(j) == 2)
                cf = cf + 1; 
            end
        end        
    end
    if cf > 0 && cf < c
        penalty = alpha*(c/cf); 
    end
    if cf == 0
        penalty = alpha*c;
    end
    fitmat(m) = sum(bch) - penalty; 
end
avgsum_init = sum(fitmat)/length(fitmat) 
% Select best parents for next generation
[sortarr,indarr] = sort(fitmat,'descend');

% Make pool of parent solutions
% MUST BE AN EVEN NUMBER
numpar_gen = 3*numchromo/5; 
max_generations = 300; 
generations = 1; 

childreninto = zeros(numpar_gen/4-1,numsens);

tic
% Main loop iterating through the generation
while(generations < max_generations)

% Probability of being chosen
for pk = 1:numpar_gen   
    prob_par(pk,1) = fitmat(indarr(pk))/sum((fitmat(indarr(1:numpar_gen)))); 
end

% Select half of the pool for reproduction
repIter = 1; 
bRep = true; 
par_out = zeros(numpar_gen/2,1); 
for i = 1:numpar_gen/2
    randRep = rand();
    bRep = true; 
    repIter = 1; 
    while(bRep)
        randRep = randRep - prob_par(repIter);
        if randRep < 0
            bRep = false; 
            indeRep = repIter; 
        end
        repIter = repIter + 1;                
    end
    par_out(i) = indeRep; 
end
% par_out now contains the indices of the individuals 
% in the mating pool. These chormosomes should undergo 
% crossover and mutation

par = indarr(1:numpar_gen,1);

children_out = zeros(numpar_gen/2-1,numsens); 
for i = 1:numpar_gen/2-1
    par1 = par_out(i); 
    par2 = par_out(i+1); 
    
    % Mutation Rate 
    p_m = 3/4; 
       
    % Crossover function
    CroP1 = sort(chromo(par1,1:end));
    CroP2 = sort(chromo(par2,1:end));

    scP1 = fitmat(par1); 
    scP2 = fitmat(par2); 

    ProbP1 = scP1/(scP1+scP2); 
    ProbP2 = 1-ProbP1;
    rCro = rand(); 
    for Ci = 1:numsens 
        if(CroP1(Ci) == CroP2(Ci))
            ChiCro(Ci) = CroP1(Ci); 
        end
        if(CroP1(Ci) ~= CroP2(Ci))
            if rCro <= ProbP1
                ChiCro(Ci) = CroP1(Ci);
            else
                ChiCro(Ci) = CroP2(Ci);
            end
        end
    end
    randMutProb = rand(); 
    if(randMutProb < p_m)

        bMut = true; 
        arrMut = zeros(numsubs,1); 

        rMut = randi(numsens,1);
        for Mi = 1:numsubs 
            for Ni = 1:numsens 
                if(ChiCro(Ni) == Mi)
                    arrMut(Mi) = 1;
                end
            end
        end
        hMut = find(arrMut == 0);
        riMut = randi(length(hMut),1);         
        ChiCro(rMut) = hMut(riMut);
     end

children_out(i,1:numsens) = ChiCro;   
end

% Select best half+1 of the children to bring into the population
fitchildren = zeros(numpar_gen/2-1,1); 
for m = 1:numpar_gen/2-1
    bch = false(usize,1); 
    for n = 1:numsens 
        inde = children_out(m,n); 
        bch(1:end,1) = bch(1:end,1) | b(1:end,inde); 
    end
    fitchildren(m) = sum(bch);
end

[chilsorted,indchild] = sort(fitchildren,'descend');
children_out(indchild(1:6),1:end);
% Into population : childreninto ->
childreninto(1:numpar_gen/4-1,1:end) = children_out(indchild(1:numpar_gen/4-1,1:end),1:end);
% New population
for i = 1:length(childreninto)
   chromo(indarr(end-i),1:end) = childreninto(i,1:end);    
end
chromo(450:end,1:end);
% Fitness of new population
fitmat = zeros(numchromo,1); 
for m = 1:numchromo
    bch = false(usize,1); 
    cove = zeros(1,ldata);
    cove(1:end) = init_cov(1:end);
    cf = 0; 
    penalty = 0; 
    barr = zeros(1,ldata); 
    for n = 1:numsens 
        inde = chromo(m,n);        
        for i = 1:ldata
            if( b(i,inde))
                barr(i) = barr(i) + 1; 
            end                                
        end
    end
    for j = 1:ldata
        if(barr(j) >= init_cov(j))
            bch(j) = true; 
            if(annot(j) == 2)
                cf = cf + 1; 
            end
        end        
    end
    if cf > 0 && cf < c
        penalty = alpha*(c/cf); 
    end
    if cf == 0
        penalty = alpha*c;
    end
    fitmat(m) = sum(bch) - penalty; 
end

% Select best parents for next generation
[sortarr,indarr] = sort(fitmat,'descend');
best(generations) = sortarr(1);

generations = generations + 1;
end
toc
sortarr(1:10);
outVal = chromo(indarr(1),1:end);

% Post process
[panx,camx] = EvalNum(lpans,outVal);

% Display Results
disp('Camera Positions x : ')
campx(camx)

disp('Camera Positions z : ')
campz(camx)

disp('Pan Angles [rad] : ')
pans(panx)