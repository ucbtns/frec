function [u,v] = spm_MDP_VB_LFPn(MDP,UNITS,f,number)

 
% defaults
%==========================================================================
try, f;          catch, f        = 1;  end
try, UNITS;      catch, UNITS    = []; end
SPECTRAL = 0;
try, MDP = spm_MDP_check(MDP);         end

% dimensions
%--------------------------------------------------------------------------
Nt     = length(MDP);               % number of trials
try
    Ne = size(MDP(1).xn{f},4);      % number of epochs
    Nx = size(MDP(1).B{f}, 1);      % number of states
    Nb = size(MDP(1).xn{f},1);      % number of time bins per epochs
catch
    Ne = size(MDP(1).xn,4);         % number of epochs
    Nx = size(MDP(1).A, 2);         % number of states
    Nb = size(MDP(1).xn,1);         % number of time bins per epochs
end

% units to plot
%--------------------------------------------------------------------------
ALL   = [];
for i = 1:Ne
    for j = 1:Nx
        ALL(:,end + 1) = [j;i];
    end
end
if isempty(UNITS)
    UNITS = ALL;
end
    
% summary statistics
%==========================================================================
for i = 1:Nt
    
    % all units
    %----------------------------------------------------------------------
    str    = {};
    try
        xn = MDP(i).xn{f};
    catch
        xn = MDP(i).xn;
    end
    for j = 1:size(ALL,2)
        for k = 1:Ne
            disp(j)
            zj{k,j} = xn(:,ALL(1,j),ALL(2,j),k);
            xj{k,j} = gradient(zj{k,j}')';
        end
        str{j} = sprintf('%s: t=%i',MDP(1).label.name{f}{ALL(1,j)},ALL(2,j));
    end
    z{i,1} = zj;
    x{i,1} = xj;
    
    % selected units
    %----------------------------------------------------------------------
    for j = 1:size(UNITS,2)
        for k = 1:Ne
            vj{k,j} = xn(:,UNITS(1,j),UNITS(2,j),k);
            uj{k,j} = gradient(vj{k,j}')';
        end
    end
    v{i,1} = vj;
    u{i,1} = uj;
    
    % dopamine or changes in precision
    %----------------------------------------------------------------------
    if size(mean(MDP(i).dn,2),1) == 32
        dn(:,i) = mean(MDP(i).dn,2);
    else
        dn(:,i) = ones(32,1)*0.125;
     end

end

if nargout, return, end
 
% phase amplitude coupling
%==========================================================================
dt  = 1/64;                              % time bin (seconds)
t   = (1:(Nb*Ne*Nt))*dt;                 % time (seconds)
Hz  = 4:32;                              % frequency range
n   = 1/(4*dt);                          % window length
w   = Hz*(dt*n);                         % cycles per window
U = spm_cat(u);
X = spm_cat(x);
 
% local field potentials
%==========================================================================
plot(t,U(:,number),'b'),     hold on, spm_axis tight, a = axis;
plot(t,spm_cat(X(:,number)),':'), hold on
plot(t,spm_cat(U(:,number)),'b'),     hold on, axis(a)
for i = 2:2:Nt
    h = patch(((i - 1) + [0 0 1 1])*Ne*Nb*dt,a([3,4,4,3]),-[1 1 1 1],'w');
    set(h,'LineStyle',':','FaceColor',[1 1 1] - 1/32);
end
ylim([-.12, .3]);


