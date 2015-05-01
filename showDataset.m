function showDataset( customers, depots, ms )
% Plots the positions of the customers and the depots

if nargin < 3
    ms = 2;
end

scatter(customers(:,1), customers(:,2), 20, 'o', 'LineWidth', ms);

hold on
scatter(depots(:,1), depots(:,2), 50, 's', 'LineWidth', 0.1, 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0]);

axis equal
hold off

end

