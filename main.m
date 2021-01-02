function main(sim)

%{
Purpose: run the word repetition simulations and plot the results.
Input:
        - sim == 0 : plotting routine opens existing results
        - sim == 1 : run simulations + plotting routines

        # Note: Simplex code is in python! 
%}


% Add appropriate functions: 
addpath ~/src
addpath ~/spm12/toolbox/DEM/
addpath ~/spm12/


if ~exist('simulation','var'), sim=0; end
if ~exist('model_number','var'), model_number=5; end
path = '~\results\';

if ~exist(path, 'dir')
       mkdir(path)
end

%% Run Simulation:
if sim == 1
    simulation(path);
end

%% Load Data:
d = dir(path);
model_names=d(~ismember({d.name},{'.','..'})); clear d;

models = {};
performance = zeros(model_number,1000);

for i = 1:model_number
    % Load modles: 
    models{i} = load(strcat(path, model_names(i).name), 'M');
     % Get functional performance:
     performance(i, :) = score(models{i}.M);
end
    

%% Figure 2 'performance': 
performance = transpose(performance);
for i = 1:5
    for j = 1:1000
        performance(j,i) = performance(j,i) / j;  
    end
end

performance = transpose(performance);
ln_pe = rescale(performance)*100;
plot1 = plot(1:1000, ln_pe([2 4 1 3],1:1000),'LineWidth',2);
set(plot1(1),'DisplayName','[#1]',...
    'Color',[0.631372549019608 1 1]);
set(plot1(2),'DisplayName','[#2]',...
    'Color',[0.301960784313725 0.745098039215686 0.933333333333333]);
set(plot1(3),'DisplayName','[#3]',...
    'Color',[0 0.447058823529412 0.741176470588235]);
set(plot1(4),'DisplayName','[#4]',...
    'Color',[0 0 0.458823529411765]);

ylabel('Percent Correct (%)','FontSize', 15) 
xlabel('Trial Number ','FontSize', 15) 
legend( 'Lesion 1 ', ....
            'Lesion 2',   ...
            'Lesion 3',   ...
            'Lesion 4',   ...    
            'Location', 'best', ....
            'FontSize', 16);
xlim([1 1000]); ylim([0 100]);

saveas(gcf, strcat('~\figures\','figure_2.tiff'))


%% Figure 3: Free Energy 
t = 2;
X = 1;
n = 1000;

total = zeros(10, 6);
i = 0;

for z = [5 2 1 4 3]
    for j =1:1000
            [entropy{j},  energy{j}, cost{j}, accuracy{j}, redundancy{j}]  = free_energy_decomp(models{z}.M.mdp(j));
    end
    aventropy = average_quantity(entropy,n);
    avenergy = average_quantity(energy,n);
    avcost = average_quantity(cost,n);
    avaccuracy = average_quantity(accuracy, n);
    avredundancy = average_quantity(redundancy, n);
    clear entropy  energy cost accuracy redundancy
    [entropy,  energy, cost, accuracy, redundancy]  = free_energy_decomp(models{z}.M);
    i = i + 1;
    total(i,:) = [avredundancy - avaccuracy, avredundancy, avaccuracy, aventropy, avenergy, avcost];
    i = i + 1;
    total(i,:) = [sum(redundancy) - sum(accuracy), sum(redundancy), sum(accuracy),  sum(entropy),  sum(energy),  sum(cost)];
    clear entropy  energy cost accuracy redundancy    
end


t = zeros(5, 6);
t(1,:) = sum(total(1:2,:)); % control 
t(2,:) = sum(total(3:4,:)); % dp precision
t(3,:) = sum(total(7:8,:)); % ep precision
t(4,:) = sum(total(5:6,:)); % dp no precision
t(5,:) = sum(total(9:10,:)); % ep no precision


figure1 = figure;
axes1 = axes('Parent',figure1);
hold(axes1,'on');

bar1 = bar(transpose(t(:,[1 4 2]))); 
set(bar1(5),'DisplayName','Control','CData',1,'FaceColor',...
 [0 0 0.458823529411765] );
set(bar1(4),'DisplayName','Degeneracy with precision','CData',2,...
    'FaceColor',[0 0.447 0.741]);
set(bar1(3),'DisplayName','Experience-dependent plasticity with precision','CData',3,...
    'FaceColor',[0.301960784313725 0.745098039215686 0.933333333333333]);
set(bar1(2),'DisplayName','Degeneracy with low precision','CData',4,...
    'FaceColor',[0.631372549019608 1 1]);
set(bar1(1),'DisplayName','Experience-dependent plasticity with low precision','CData',5,...
    'FaceColor',[0 0 0]);

box(axes1,'on');
ylabel('Natural Units (Nats)'); 
set(axes1,'FontSize',11,'XTick',[1 2 3],'XTickLabel',...
    {'Free Energy','Degenerancy', 'Redundancy'});

ylabel('Natural Units (Nats)'); 
xticklabels({'Free Energy', 'Degenerancy', 'Redundancy'});
legend1 = legend(axes1, 'Lesion 0',...
            'Lesion 1 ', ....
            'Lesion 2',   ...
            'Lesion 3',   ...
            'Lesion 4',   ...
            'Location', 'best', ....
            'FontSize', 16);
set(legend1,'Location','northeast','FontSize',16);

saveas(gcf, strcat('~\figures\','figure_3.tiff'))


%%  Figure 4 Link between initial severity + performance 
i = 0;
n = 50;
for z = [5 2 1 4 3]
    for j =1:50
            [entropy{j},  energy{j}, cost{j}, accuracy{j}, redundancy{j}]  = free_energy_decomp(models{z}.M.mdp(j));
    end
    aventropy = average_quantity(entropy,n);
    avenergy = average_quantity(energy,n);
    avcost = average_quantity(cost,n);
    avaccuracy = average_quantity(accuracy, n);
    avredundancy = average_quantity(redundancy, n);
    clear entropy  energy cost accuracy redundancy
    [entropy,  energy, cost, accuracy, redundancy]  = free_energy_decomp(models{z}.M);
    i = i + 1;
    total(i,:) = [avredundancy - avaccuracy, avredundancy, avaccuracy, aventropy, avenergy, avcost];
    i = i + 1;
    total(i,:) = [sum(redundancy) - sum(accuracy), sum(redundancy), sum(accuracy),  sum(entropy),  sum(energy),  sum(cost)];
    clear entropy  energy cost accuracy redundancy    
end

t = zeros(5, 6);
t(1,:) = sum(total(1:2,:)); % control 
t(2,:) = sum(total(3:4,:)); % dp precision
t(3,:) = sum(total(7:8,:)); % ep precision
t(4,:) = sum(total(5:6,:)); % dp no precision
t(5,:) = sum(total(9:10,:)); % ep no precision

perf2 = performance([2 4 1 3],1000)*100;
subplot(3,1,1);
bar1 = bar(perf2,t(2:end,1));
ylabel('Initial Free Energy','FontSize', 15) 
xlabel('Behavioural Performance (%)','FontSize', 15) 
subplot(3,1,2);
bar2= bar(perf2,t(2:end,4));
ylabel('Initial Degeneracy','FontSize', 15) 
xlabel('Behavioural Performance (%)','FontSize', 15) 
subplot(3,1,3);
bar3= bar(perf2,t(2:end,2));
ylabel('Initial Redundancy','FontSize', 15) 
xlabel('Behavioural Performance (%)','FontSize', 15) 

saveas(gcf, strcat('~\figures\','figure_4.tiff')) % note the colors are updating using the GUI


%% Figure 5 - Dirichlet 
p1 = models{4}.M.MDP.b{2}(1:3, 1);
p2 = models{4}.M.mdp(10).b{2}(1:3, 1);
p3 = models{4}.M.mdp(30).b{2}(1:3, 1);
p4 = models{4}.M.mdp(100).b{2}(1:3, 1);
p5 = models{4}.M.mdp(500).b{2}(1:3, 1);
p6 = models{4}.M.mdp(1000).b{2}(1:3, 1);

pn = models{5}.M.MDP.B{2}(1:3, 1);
% Dirchlets plotting using python (simplex2d.py)


%% Figure 6: 'firing rates'
model_n = {'Lesion 0', 'Lesion 1', 'Lesion 2', 'Lesion 3', 'Lesion 4'};
z= 1;
for i = [5 2 4 1 3 ]
    clear M
    M = models{i}.M.mdp([1:300 ]); 
    % calculate the gradient 
    subplot(5,1,z);
    spm_MDP_VB_LFP_Single(M,[],2,9); hold on
    if z == 1
        title('Local field potentials','FontSize',16)
    elseif z == 5
        xlabel('time (sec)','FontSize',16,'FontWeight','bold')
    end
    ylabel(model_n{z},'FontSize',16,'FontWeight','bold')
    z = z + 1;
end
hold off

saveas(gcf, strcat('~\figures\','figure_6.tiff')) %Note the highlighted regions done manually

