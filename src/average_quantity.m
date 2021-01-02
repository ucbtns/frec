function av = average_quantity(quantity, n)

quantity_lower = quantity;

av =0;
for i = 1:n
      av = av + quantity_lower{i};
end

av = sum(sum(av));
return 