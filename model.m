function mdp = model(seed, one, two,  p)


rng(seed)
if ~exist('t','var'), t=2; end
if ~exist('one','var'), one=0; end
if ~exist('two','var'), two=0; end
if ~exist('p','var'), p=0; end

% Lower level:
%--------------------------------------------------------------------------
% P(S_0)
%--------------------------------------------------------------------------
n = 5;
D{1} = ones(n,1)*1;           % Content: what I said?:  X 2
D{2} = ones(n,1)*10 ;        % Target: what is the true context?
D{3} = [128 0]';                 % Time: {1, 2, 3}
D{4} = [1 1]';                          % Homologue {1,2}

%--------------------------------------------------------------------------
% P(O|S)
%--------------------------------------------------------------------------
Nf = numel(D); 
for f = 1:Nf
    Ns(f) = numel(D{f}); 
end
No    = [2 3 n]; 
Ng    = numel(No); 


e = 0;
for g = 1:Ng
    A{g} = ones([No(g),Ns])*e; 
end

for f1 = 1:Ns(1) 
    for f2 = 1:Ns(2)  
        for f3 = 1:Ns(3)  
            for f4 = 1:Ns(4) 
             
                       if (f3 == 1 )
                            A{1}(1,1:n,:,f3, 1) = 1;
                            A{1}(1,1:n,:,f3, 2) = p;
                            A{1}(2,1:n,:,f3, 2) = 1-p;
                            
                        elseif (f3 == 2)
                            A{1}(2,1:n,:,f3, 1) = 1;
                            A{1}(2,1:n,:,f3, 2) = p;
                            A{1}(1,1:n,:,f3, 2) = 1-p;
                       end 
                        
                         if f3 == 1 
                            A{2}(3,1:n,:,f3, 1) = 1;     
                            A{2}(3,1:n ,:,f3, 2) = p;     
                            A{2}(1:2,1:n,:,f3, 2) = 1-p; 
                            
                        elseif (f1 ~= f2)
                            
                           A{2}(2,f1,f2,f3, 1) = 1; 
                           A{2}(2,f1,f2,f3, 2) =p; 
                           A{2}([1,3],f1,f2,f3, 2) =1-p; 
                      
                        elseif (f2 == f1) 
                        
                            A{2}(1,f1,f2,f3, 1) = 1;
                            A{2}(1,f1,f2,f3, 2) = p;     
                            A{2}(2:3,f1,f2,f3, 2) = 1-p;         
                        end   
                                         
                        if f3 == 1
                            A{3}(:,f1, :,f3, 1) = [ones(n,n)*e+eye(n,n)];  
                            A{3}(:,f1, :,f3, 2) = [ones(n,n)*1-p+(p-(1-p))*eye(n,n)]; 
                        else
                             A{3}(:,1:end,f2,f3, 1) = [eye(n,n)];
                             A{3}(:,1:end,f2,f3, 2) = (p-(1-p))*eye(n,n)+1-p;
                        end 
            end
        end
    end       
end



if one == 1 
    for f1 = 1:Ns(1) 
        for f2 = 1:Ns(2)  
            for f3 = 1:Ns(3)  
                    A{3}(:,:,:,:,1) = 1;     
                    A{2}(:,:,:,:,1) = 1;
                    A{1}(:,:,:,:,1) = 1;
            end
        end
    end
end
 

if one == 2
    z = 0.6;   
    for f1 = 1:Ns(1) 
        for f2 = 1:Ns(2)  
            for f3 = 1:Ns(3) 
                for f4 = 1:Ns(4)
                          A{1}(:,:,f2,f3,1) = A{1}(:,:,f2,f3,2);
                          A{2}(:,:,f2,f3,1) = A{2}(:,:,f2,f3,2);
                          A{3}(:,:,f2,f3,1) = A{3}(:,:,f2,f3,2);
                          
                          a{1}(:,:,f2,f3,2) =  spm_softmax(z*log(A{1}(:,:,f2,f3,2) +1));                         
                          a{1}(:,:,f2,f3,1) =  spm_softmax(z*log(A{1}(:,:,f2,f3,2) +1));   
                          a{2}(:,:,f2,f3,2) =  spm_softmax(z*log(A{2}(:,:,f2,f3,2)+1));                         
                          a{2}(:,:,f2,f3,1) =  spm_softmax(z*log(A{2}(:,:,f2,f3,2) + 1));   
                          a{3}(:,:,f2,f3,2) =  spm_softmax(z*log(A{3}(:,:,f2,f3,2) + 1));                         
                          a{3}(:,:,f2,f3,1) =  spm_softmax(z*log(A{3}(:,:,f2,f3,2) + 1));   
                end
            end
        end
    end  
end

for g = 1:Ng
        a{g} = A{g}*10;
end 

%--------------------------------------------------------------------------
% P(S_t| S_t-1, pi)
%--------------------------------------------------------------------------
for f = 1:Nf
        B{f} = e*ones(Ns(f));
end

 for i = 1:n
    B{1}(i,:,i) = 1;
 end 

B{2} = eye(n);
B{3} = [0 0; 1 1];
B{4}(:,:,1) = eye(2) + 0.05;

for f = 1:Nf
        b{f} = B{f}*10;
end

if two == 1 
    b{2} = ones(5)*0.2;
end

if two == 2 
    b{2} = spm_softmax(0.4*log(eye(5)+1));
end


%------------------------------------------------------------------------------
% P(o)
%------------------------------------------------------------------------------
for g = 1:Ng
    C{g}  = zeros(No(g),t);
end

c = 5;
C{2}(1,:) =  c; 
C{2}(2, :) = -c;

%--------------------------------------------------------------------------
% Specify the generative model
%--------------------------------------------------------------------------
mdp.T = t;                     
mdp.A = A;  
mdp.B = B;                      
mdp.C = C;                      
mdp.D = D;   
mdp.chi = 1/exp(16);

mdp.b = b;
mdp.a = a;



% Labels:
mdp.label.modality = {'Proprio.' 'Evaluation' 'Word'};
mdp.label.outcome{1} = {'Other' 'Me'};
mdp.label.outcome{2} = {'Right' 'Wrong' 'None'};
mdp.label.outcome{3} =   {'red' 'square' 'triangle' 'blue' 'table' };

mdp.label.factor{1} = 'Repeated Word';  
mdp.label.factor{2} = 'Target Word'; 
mdp.label.factor{3} = 'Epoch'; 
mdp.label.factor{4} = 'Context'; 
mdp.label.name{1} = {'red' 'square' 'triangle' 'blue' 'table'} ;
mdp.label.name{2} = {'red' 'square' 'triangle' 'blue' 'table' } ;
mdp.label.name{3} = { '1' '2'} ;
mdp.label.name{4} = {'attentive' 'inattentive'};


MDP       = spm_MDP_check(mdp);
clear mdp A B b C D U Ns No Nf Ng t

% --------------------------------------------------------------------
% Higher level:
% --------------------------------------------------------------------
D{1} = [0.5 0.5]';     

Nf = numel(D);
Ng = 1;

for f = 1:Nf
    Ns(f) = numel(D{f}); 
end

label.factor =  { 'Attention'};
label.name{1} =  {'yes' 'no'};
label.modality{1} = MDP.label.factor{4} ;
label.outcome{1}  = [MDP.label.name{4}];

for f = 1:Ng
    No(f) = numel(label.outcome{f});   
end

for g = 1:Ng
    A{g} = zeros([No(g),Ns]); 
end

A{1} = eye(2);


% Transitions: 
for f = 1:Nf
    B{f} = zeros(Ns(f));
end

B{1}(:,:,1) = spm_norm(eye(2) +0.05);


%% Policies:
U   = ones(1,1,Nf);
U(:,:,1) = [1];

%--------------------------------------------------------------------------
% Specify the generative model
%--------------------------------------------------------------------------

mdp.label = label;     
mdp.A = A;                      
mdp.B = B;  
mdp.U = U; 
mdp.D = D; 
mdp.s = 1;
mdp.T = 100; 

mdp.MDP   = MDP;
mdp.Bname = { 'Attention'};
mdp.Aname = {'Context'}; 
 
mdp.link = spm_MDP_link(mdp);   % map outputs to initial (lower) states4
mdp         = spm_MDP_check(mdp);

return 





