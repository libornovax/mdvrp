function [ output_args ] = runMDVRP( filename, cluster_method )
% Loads the data and solves the multi depot vehicle routing problem (MDVRP)
% in two steps:
%   1) Cluster the costomers
%   2) Solve VRP for each cluster



%% Load the dataset
[customers, depots, loads, durations, num_vehicles] = loadDataset(filename);

% Show the loaded data
figure;
showDataset(customers, depots);
title('Dataset');


%% Cluster the data
% There are several methods available:
%   1 = K-Means
if nargin < 2
    % default if not provided
    cluster_method = 1;
end

addpath('clustering');
assignments = zeros(size(customers, 1), 1);
switch cluster_method
    case 'kmeans'
        % K-Means
        assignments = clusterKMeans(customers, depots);
        
    case 'lncl'
        % Evolutionary algorithm clustering (LNCl)
        assignments = LNCl(customers, depots, num_vehicles*loads(1)); % all vehicles are the same
        
    otherwise
        disp('runMDVRP(): Unsupported clustering method!');
        return
end

% Show the clusters
figure;
showClusters(customers, depots, assignments);
title('Depot assignment');


%% Solve the VRPs
% We will use the simple Clarke and Wright method
routes = cell(0);
depotsi = [];
for i = 1:size(depots, 1)
    % Solve the VRP for each depot
    rts = ClarkeAndWright(customers(assignments == i, :), depots(i, :), loads(i), durations(i), num_vehicles);
    
    routes = [routes rts];
    depotsi = [depotsi ones(1, length(rts))*i];
end

% draw routes
figure;
showDataset(customers, depots, 1);
hold on
rtl = 0;
for i = 1:length(routes)
    clstr = customers(assignments == depotsi(i), :);
    plot([depots(depotsi(i), 1); clstr(routes{i}, 1); depots(depotsi(i),1)], [depots(depotsi(i), 2); clstr(routes{i}, 2); depots(depotsi(i), 2)]);
    
    rtl = rtl + routeLength(clstr, depots(depotsi(i), :), routes{i});
end
title(['Solution of MDVRP. Length = ' num2str(rtl)])


end

