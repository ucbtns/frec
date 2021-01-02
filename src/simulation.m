
function simulation(path)

if ~exist('path','var'), path = '~\results\'; end  

total = 5;
i = 1;
j = 'default'; 

% Baseline: 
mdp = model(j,0, 0, 0.9,1000,1000);
M = spm_MDP_VB_X(mdp);
save(strcat(path, 'nbaseline.mat'), 'M');

display(strcat('Getting warmed up:  ', num2str(round((i/total)*100)), '% completed.'))
i = i + 1;
clear M mdp

% Degeneracy + Precise:  
mdp = model(j,1, 0, 0.9,1000,1000);
mdp.eta = 0;
M = spm_MDP_VB_X(mdp);
save(strcat(path, 'nD_p.mat'), 'M'); 

display(strcat('Getting warmed up:  ', num2str(round((i/total)*100)), '% completed.'))
i = i + 1;
clear mdp M

% Degeneracy + imPrecise:  
mdp = model(j,3, 0, 0.9,1000,1000);
mdp.eta = 0;
M = spm_MDP_VB_X(mdp);
save(strcat(path, 'nCD_p.mat'), 'M'); 

display(strcat('Getting warmed up:  ', num2str(round((i/total)*100)), '% completed.'))
i = i + 1;
clear mdp M

% Experience Dependent Plasticity + Precision:
mdp = model(j,1, 2, 0.9,1000,1);
mdp.MDP.eta = 2;
M= spm_MDP_VB_X_learning(mdp);

save(strcat(path, 'nEDP_p.mat'), 'M');
display(strcat('Getting warmed up:  ', num2str(round((i/total)*100)), '% completed.'))
i = i + 1;

clear M mdp

% Degeneracy + Not Precise:
mdp = model(j,2, 0, 0.2,1000,1000);
mdp.eta = 0;
M = spm_MDP_VB_X(mdp);
save(strcat(path, 'nD_np.mat'), 'M');

display(strcat('Getting warmed up:  ', num2str(round((i/total)*100)), '% completed.'))
clear M mdp

% Experience Dependent Plasticity, Degeneracy + Not Precise:
mdp = model(j,2, 2, 0.9,1000,1);
mdp.MDP.eta = 2;
M = spm_MDP_VB_X_learning(mdp);

save(strcat(path, 'nEDP_np.mat'), 'M');

display(strcat('Completed.'))

return 