%% Show all datasets

flnms = cell(0);
for i = 1:23
    flnms{i} = sprintf('p%02d', i);
end
for i = 1:10
    flnms{23+i} = sprintf('pr%02d', i);
end

for i = 1:length(flnms)
    [ customers, depots, loads, durations, num_vehicles ] = loadDataset(['data/C-mdvrp/' flnms{i}]);
    figure;
    showDataset(customers, depots);
    title(['Dataset ' flnms{i}]);
    pause(0.1);
end