%% Generate Combinations
clc; clear 
% User Need to Specify 
%   - k : Number of cameras
%   - n : Number of possible placement points
n = 249; 
k = 5;
e = CombinaisonEnumerator(k, 249);

%% This part of the script needs to be executed several times 
% Ctrl + Left Click for execution of this section only
clear A
limiter = 1;
maxlim = 1.5e8; 
ncams = 5; 
A = zeros(maxlim,ncams);
tic
while(e.MoveNext() && limiter < maxlim + 1)

    A(limiter,1:ncams) = e.Current + 45; 
    limiter = limiter + 1; 
end
toc
tic
mex_WriteMatrix('combtests_1.txt',A,'%f',' ', 'w+');
toc
A(end,:)