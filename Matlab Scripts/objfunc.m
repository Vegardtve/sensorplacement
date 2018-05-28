function val = objfunc(p,yi,ncams)
%Import problem structure
env = environment_generate('mini_0705.mat');  
datax = env.datax;                          
datay = env.datay;                          
dataz = env.dataz;                          
obsta = env.obsta;
annot = env.annot; 

ldata = length(datax); 
b = zeros(ncams,ldata); 
alpha = 4000; 
% Compute coverage of all data points 
for i = 1:ncams
    x = p(5 + i);
    y = yi(i); 
    z = p(10 + i);
    for n = 1:ldata
        b(i,n) = covered1(n,x,y,z,datax,datay,dataz,...
                        obsta,p(i));
    end
end
c = 0;
% Initialize array of required coverage
init_cov = zeros(ldata,1); 
for i = 1:ldata
    if(annot(i) == 2)
        init_cov(i) = 2; 
        c = c + 1;
    else 
        init_cov(i) = 1; 
    end
end
cove = zeros(ldata,1); 
cf = 0; 
tot = 0; 
penalty = 0; 
bch = false(ldata,1); 
% Evaluate coverage
for j = 1:ncams
    for i = 1:ldata
        if( b(j,i) )
            cove(i) = cove(i) + 1; 
        end
    end
end
for k = 1:ldata
    if(cove(k) >= init_cov(k))
        bch(k) = true; 

        if(init_cov(k) == 2)               
            cf = cf + 1;   
        end
    end
end

% Penalize solutions that does not fully cover the ROI
if cf > 0 && cf < c
    penalty = alpha*(c/cf); 
end
if cf == 0
    penalty = alpha*c;
end

sumt = sum(bch) - penalty;
if sumt <= 0
    sumt = 1; 
end
val = 100000/sumt; % Output value
end
