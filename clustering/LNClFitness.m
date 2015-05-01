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


%% %%%%%%%%%%%%%%  NEW FITNESS FUNCTIONS %%%%%%%%%%%%%% %%

%% No. 1 - Distance to the two closest neighbors from the cluster
% For each customer in each cluster we add to the total fitness the
% distances to the closest and second closest neighbor from the cluster
% 
% Note: It creates compact local clusters, however spread across the whole
% map, which is not ideal
%

% num_depots = size(depots, 1);
% % Distance to two closest customers
% for i = 1:length(fitness)
%     % For each individual compute fitness
%     for d = 1:num_depots
%         % For each depot compute the evaluation - for each customer find 2 closest ones from the cluster
%         csi = find(population(:,i) == d);
%         
%         % Careful! Here we have to select only the distances to the
%         % customers in the current cluster
%         [D_sorted, Icurrent] = sort(D(csi,csi), 2, 'ascend');
%         customers_current = customers(csi,:);
%         
%         if size(Icurrent, 2) < 3
%             % Cluster has less than 3 customers - we cannot find two closest
%             fitness(i) = fitness(i) + 100;
%         else
%             closest = Icurrent(:, 2:3); % closest customers
% 
%             dsts1 = sum((customers_current(:,1:2) - customers_current(closest(:,1),1:2)).^2, 2);
%             dsts2 = sum((customers_current(:,1:2) - customers_current(closest(:,2),1:2)).^2, 2);
%             fitness(i) = fitness(i) + sum(dsts1) + sum(dsts2);
%             
% %             fitness(i) = fitness(i) + sum(D(sub2ind(size(D),csi,closest(:,1)))) + sum(D(sub2ind(size(D),csi,closest(:,2))));
%         end
%     end
% end


%% No. 2 - Distance to the closest not yet paired customer in the cluster
% Use only the first nearest, but do not repeat - if they are mutualy
% nearest, the other customer must select a second nearest etc...
%   - This way I should not get so many 'lonely islands'
%
% Note: But I still get some, the compactness or route is not ideal
%

num_depots = size(depots, 1);
% Distance to two closest customers
for i = 1:length(fitness)
    % For each individual compute fitness
    for d = 1:num_depots
        % For each depot compute the evaluation - for each customer find 2 closest ones from the cluster
        csi = find(population(:,i) == d);
        
        while length(csi) > 1
            % Sort the customers that are still considered (with
            % respect to the distance to the first customer
            [D_sorted, Icurrent] = sort(D(csi(1),csi), 2, 'ascend');
            customers_current = customers(csi,:);

            closest = Icurrent(1, 2); % closest customer to the first one

            dst = sum((customers_current(1,1:2) - customers_current(closest,1:2)).^2, 2);
            fitness(i) = fitness(i) + dst;
            
            % Remove the already used costomer
            csi(1) = [];
        end
    end
end

end

