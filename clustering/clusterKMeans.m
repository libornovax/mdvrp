function assignments = clusterKMeans( customers, depots )
% Cluster the customers with K-Means. Which is essentially just assigning
% the customer to the closest depot

% Create the matrix of distances
rows = size(customers, 1);
cols = size(depots, 1);
D = zeros(rows, cols);
for i = 1:rows
    for j = 1:cols
        D(i,j) = sum((customers(i,1:2) - depots(j,1:2)).^2);
    end
end

% Find the closest depot in each row
[D_sorted, I] = sort(D, 2);
assignments = I(:, 1);

end

