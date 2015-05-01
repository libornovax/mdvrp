[customers, depots, loads, durations, num_vehicles] = loadDataset('data/C-mdvrp/p07');

% Matrix of distances
num_customers = size(customers, 1);
D = zeros(num_customers, num_customers);
for ii = 1:num_customers
    for jj = 1:num_customers
        D(ii,jj) = sum((customers(ii,1:2) - customers(jj,1:2)).^2);
    end
end


csi = [2   86    74    22    41    80    85    92    46    97    21    73    72    68    93    37   95    83    87    57    15    47    54    26    65];
csi = csi(randperm(length(csi)));

customers_current = customers(csi,:);

% Sort the customers with respect to the distance to the current customer
[D_sorted, Icurrent] = sort(D(csi,csi), 2, 'ascend');

% Indices of customers which are apired with the customers in csi
% Indices in D(csi,csi)!! not global!
paired = zeros(size(csi));

fitness = 0;
for c = 1:length(csi)
    % For each customer find the closest available in the set
    if paired(c) ~= 0
        continue;
    end

    % closest customer, which is not paired
    closest = 0; 
    for j = 2:length(csi)
        if paired(Icurrent(c, j)) == 0
            % The closest is not paired twice yet and is not paired
            % with the current custommer
            closest = Icurrent(c, j);

            break;
        end
    end
    
    if closest == 0
        % When the number of customers is odd
        continue;
    end
    
    dst = sum((customers_current(1,1:2) - customers_current(closest,1:2)).^2, 2);
    fitness = fitness + dst;

    % Set the pairing
    paired(closest) = c;
    paired(c) = closest;
end
paired

new_order = randperm(length(csi));
csi = csi(new_order)
paired = paired(new_order);
customers_current = customers(csi,:);
% Sort the customers with respect to the distance to the current customer
[D_sorted, Icurrent] = sort(D(csi,csi), 2, 'ascend');
for c = 1:length(csi)
    % For each customer find the closest available in the set
    if paired(c) < 0
        % This cusotmer already is in 2 pairs
        continue;
    end

    % closest customer, which is not paired twice or with the current one
    closest = 0; 
    for j = 2:length(csi)
        if paired(Icurrent(c, j)) >= 0 && paired(Icurrent(c, j)) ~= c
            % The closest is not paired twice yet and is not paired
            % with the current custommer
            closest = Icurrent(c, j);

            break;
        end
    end
    if closest == 0
        % There probably is an isolated customer
        fitness = fitness + 100000;
        continue;
    end
    
    dst = sum((customers_current(1,1:2) - customers_current(closest,1:2)).^2, 2);
    fitness = fitness + dst;

    % Set the pairing
    if paired(closest) > 0
        % This is the second pair
        paired(closest) = -1;
    else
        paired(closest) = c;
    end
    if paired(c) > 0
        % This is the second pair
        paired(c) = -1;
    else
        paired(c) = closest;
    end
end
paired
fitness