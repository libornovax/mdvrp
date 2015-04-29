function indiv_rep = repairIndividual( indiv, customers, depots, depot_capacity )
% Repairs the individual to satisfy the constraint of max depot capacity
% for each depot.
%
% Input:
%   indiv = nx1 vector representing an individual
%   customers = nx3 matrix
%   depots = mx2 vector
%   depot_capacity = number (max depot capacity)
%

indiv_rep = indiv;

num_depots = size(depots, 1);
% disp(['Depot capacity: ' num2str(depot_capacity)]);

D = cell(0); % Cell array containing all depots
De = []; % list of depots with excessive demand
Di = [];

for d = 1:num_depots
    % For each depot compute its requested demand by the current depot assignment
    D{d}.cst = find(indiv == d);
    D{d}.demand = sum(customers(D{d}.cst,3));
    
    if D{d}.demand > depot_capacity
        De = [De d];
    else
        Di = [Di d];
    end
    
%     disp(['Demand for depot ' num2str(d) ' is ' num2str(D{d}.demand)]);
end


%% Repairing
while ~isempty(De)
    % Take the first excessive depot
    d = De(1);
    
    % Randomly order customers
    rpi = randperm(length(D{d}.cst));
    ci = 1;
    while D{d}.demand > depot_capacity && ci <= length(D{d}.cst)
        % Take a customer from the current cluster and try placing it to
        % another one
        Di = Di(randperm(length(Di)));
        for i = Di
            if (depot_capacity - D{i}.demand) >= customers(D{d}.cst(rpi(ci)), 3)
                % We can place the customer to cluster i
                D{i}.cst = [D{i}.cst; D{d}.cst(rpi(ci))];
                D{i}.demand = D{i}.demand + customers(D{d}.cst(rpi(ci)), 3);
                
                % Remove it from the current
                D{d}.demand = D{d}.demand - customers(D{d}.cst(rpi(ci)), 3);
                D{d}.cst(rpi(ci)) = [];
                
                rpi(rpi > rpi(ci)) = rpi(rpi > rpi(ci)) - 1;
                rpi(ci) = [];
                ci = ci - 1;
                break;
            end
        end
        
        % Try next customer
        ci = ci + 1;
    end
    
    % Remove depot from excessive ones
    De(1) = [];
    Di = [Di d];
end


%% Copy the new assignments to the individual
for d = 1:num_depots
    indiv_rep(D{d}.cst,1) = d;
    
%     disp(['NEW Demand for depot ' num2str(d) ' is ' num2str(D{d}.demand)]);
end

end

