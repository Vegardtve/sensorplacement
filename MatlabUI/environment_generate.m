function env = environment_generate(my_matfile)
% Function to produce a struct (env) of the UI output 
% from the generated *.mat file

inp = load(my_matfile);
env.datax = inp.optim{4}; 
env.datay = inp.optim{5}; 
env.dataz = inp.optim{6};
env.campx = inp.optim{2}; 
env.campz = inp.optim{3}; 
% Note: Defined as -6 for this specific problem
env.campy(1:length(env.campx)) = -6;
env.annot = inp.optim{1}; 

oc = 0;
% Determine obstacles
for ka = 1:length(env.annot)
    if env.annot(ka) == 1
        oc = oc + 1;
        env.obsta(oc,1:3) = [env.datax(ka),env.datay(ka),env.dataz(ka)];
    end
end