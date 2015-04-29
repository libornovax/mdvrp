function showDataset( customers, depots )
% Plots the positions of the customers and the depots

scatter(customers(:,1), customers(:,2), 20, 'o');

hold on
scatter(depots(:,1), depots(:,2), 50, 's', 'LineWidth', 0.1, 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0]);

axis equal
hold off

end

