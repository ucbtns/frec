
function simulation(path)

total = 5;
i = 1;

% Baseline: 
mdp = model('default',0, 0, 1);
M = spm_MDP_VB_X(mdp);
save(strcat(path, 'baseline.mat'), 'M');
display(strcat('Getting warmed up:  ', num2str(round((i/total)*100)), '% completed.'))
i = i + 1;

clear M mdp
% Degeneracy + Precise:  
mdp = model('default',1, 0, 1);
M = spm_MDP_VB_X(mdp);
save(strcat(path, 'D_p.mat'), 'M');
display(strcat('Getting warmed up:  ', num2str(round((i/total)*100)), '% completed.'))
i = i + 1;

clear mdp M
% Experience Dependent Plasticity + Precision:
mdp = model('default',1, 1, 1);
M = spm_MDP_VB_X(mdp);
save(strcat(path, 'EDP_p.mat'), 'M');
display(strcat('Getting warmed up:  ', num2str(round((i/total)*100)), '% completed.'))
i = i + 1;

clear M mdp
% Degeneracy + Not Precise:
mdp = model('default',2, 0, 0.95);
M = spm_MDP_VB_X(mdp);
save(strcat(path, 'D_np.mat'), 'M');
display(strcat('Getting warmed up:  ', num2str(round((i/total)*100)), '% completed.'))

clear M mdp
% Experience Dependent Plasticity + Not Precise:
mdp = model('default',2, 2, 0.95);
M = spm_MDP_VB_X(mdp);
save(strcat(path, 'EDP_np.mat'), 'M');


display(strcat('Completed.'))

return 