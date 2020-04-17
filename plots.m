function plots(simulation)

addpath D:\PhD\Code\paradox
addpath d:/PhD/Code/spm/toolbox/DEM/
addpath d:/PhD/Code/spm/

if ~exist('simulation','var'), sim=0; end
if ~exist('model_number','var'), model_number=5; end
path = 'D:\PhD\Code\paradox\results\';

if ~exist(path, 'dir')
       mkdir(path)
end


% Run simulation:
if sim == 1
    simulation(path);
end

d = dir(path);
model_names=d(~ismember({d.name},{'.','..'})); clear d;

models = {};
performance = zeros(model_number,100);

for i = 1:model_number
    % Load modles: 
    models{i} = load(strcat(path, model_names(i).name), 'M');
     % Get functional performance:
     performance(i, :) = score(models{i}.M);
end
    

%Figure 3: Free Energy 
t = 2;
X = 1;
n = 100;

total = zeros(10, 6);
i = 0;

for z = [5 2 1 4 3]
    for j =1:100
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
% Set the remaining axes properties
set(axes1,'FontSize',11,'XTick',[1 2 3],'XTickLabel',...
    {'Free Energy','Degenerancy', 'Redundancy'});
% Create legend

ylabel('Natural Units (Nats)'); 
xticklabels({'Free Energy', 'Degenerancy', 'Redundancy'});
legend1 = legend(axes1, 'Control',...
            'Degeneracy - high precision ', ....
            'E-D Plasticity - high precision',   ...
            'Degeneracy - low precision',   ...
            'E-D Plasticity - low precision',   ...
            'Location', 'best', ....
            'FontSize', 12);
      
set(legend1,'Location','northeast','FontSize',11);

saveas(gcf, strcat('D:\PhD\Code\paradox\figures\','red_deg.tiff'))


% Figure 5: 
p1 = models{4}.M.MDP.b{2}(1:3, 1);
p2 = models{4}.M.mdp(10).b{2}(1:3, 1);
p3 = models{4}.M.mdp(30).b{2}(1:3, 1);
p4 = models{4}.M.mdp(100).b{2}(1:3, 1);

pn = models{5}.M.MDP.B{2}(1:3, 1);
% Plotted using python (simplex2d.py)


% Figure 6: 'firing rates'
for i = [1 2 3 4 5]
    clear M
    M = models{i}.M.mdp([2:17 22:99]); 
    % removing problematic trial with no response
    % calculate the gradient 
    spm_figure('GetWin',strcat('Figure', num2str(i))); clf
    spm_MDP_VB_LFP(M,[],2);
end


% Figure X 'performance': 
plot1 = plot(1:100, performance([5 2 4 1 3],:),'LineWidth',2);
set(plot1(1),'DisplayName','Control',...
    'Color', [0 0 0] );
set(plot1(2),'DisplayName','Degeneracy - precision',...
    'Color',[0.631372549019608 1 1]);
set(plot1(3),'DisplayName','Exp. dependent plasticity - precision',...
    'Color',[0.301960784313725 0.745098039215686 0.933333333333333]);
set(plot1(4),'DisplayName','Degeneracy - low precision',...
    'Color',[0 0.447058823529412 0.741176470588235]);
set(plot1(5),'DisplayName','Exp. dependent plasticity - low precision',...
    'Color',[0 0 0.458823529411765]);

ylabel('Cumulative Beh. Performance ','FontSize', 15) 
xlabel('Number of Trials ','FontSize', 15) 
legend('Control',...
            'Degeneracy - high precision ', ....
            'E-D Plasticity - high precision',   ...
            'Degeneracy - low precision',   ...
            'E-D Plasticity - low precision',   ...
            'Location', 'best', ....
            'FontSize', 12);
xlim([1 100]); ylim([0 100]);

saveas(gcf, strcat('D:\PhD\Code\paradox\figures\','behavioural_performance.tiff'))