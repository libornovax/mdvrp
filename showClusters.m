function showClusters( customers, depots, assignments )
% Plots the positions of the customers and their assigments to the depots

scatter(customers(:,1), customers(:,2), 20, assignments, 'o');

hold on
scatter(depots(:,1), depots(:,2), 50, [1:size(depots,1)]', 's', 'MarkerFaceColor', [1 0 0]);

axis equal
hold off

end

