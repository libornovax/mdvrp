function fitness = LNClFitness( population, customers, depots, D, I )
% Computes the fitness function of all individuals in the population

fitness = zeros(1, size(population, 2));


%% Distance from each customer to thr closest depot - like K-means
% for i = 1:length(fitness)
%     % For each individual compute fitness
%     assigned_depots = depots(population(:,i), :);
%     dsts = sum((customers(:,1:2) - assigned_depots).^2);
%     
%     fitness(i) = sum(dsts);
% end


%% New suggested fitness
num_depots = size(depots, 1);
% Distance to two closest customers
for i = 1:length(fitness)
    % For each individual compute fitness
%     max_demand = 0;
%     min_demand = inf;
    for d = 1:num_depots
        % For each depot compute the evaluation - for each customer find 2 closest ones from the cluster
        csi = find(population(:,i) == d);
        
        Icurrent = I(csi, csi);
        
        if size(Icurrent, 2) < 3
            % Cluster has less than 3 customers - we cannot find two
            % closest
            fitness(i) = fitness(i) + 100;
        else
            closest = Icurrent(:, 2:3); % closest customers

            dsts1 = sum((customers(csi,1:2) - customers(closest(:,1),1:2)).^2, 2);
            dsts2 = sum((customers(csi,1:2) - customers(closest(:,2),1:2)).^2, 2);
            fitness(i) = fitness(i) + sum(dsts1) + sum(dsts2);
            
%             fitness(i) = fitness(i) + sum(D(sub2ind(size(D),csi,closest(:,1)))) + sum(D(sub2ind(size(D),csi,closest(:,2))));

%             demand = sum(customers(csi,3));
%             if demand > max_demand
%                 max_demand = demand;
%             end
%             if demand < min_demand
%                 min_demand = demand;
%             end
        end
    end
    
%     fitness(i) = fitness(i) + 20*(max_demand-min_demand);
end



end

