function s = score(M)

s = zeros(1000,3);
for i = 1:1000  
    try
        j = M.mdp(i).o(2,2);
    catch
        j = 3;
    end
    s(i,j) = 1;
end

s = cumsum(s(:,1));

return 