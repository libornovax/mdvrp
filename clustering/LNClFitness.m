function fitness = LNClFitness( population, customers, depots, D )
% Computes the fitness function of all individuals in the population

fitness = zeros(1, size(population, 2));


%% Distance from each customer to thr closest depot - like K-means
for i = 1:length(fitness)
    % For each individual compute fitness
    assigned_depots = depots(population(:,i), :);
    dsts = sum((customers(:,1:2) - assigned_depots).^2);
    
    fitness(i) = sum(dsts);
end


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

% num_depots = size(depots, 1);
% for i = 1:length(fitness)
%     % For each individual compute fitness
%     for d = 1:num_depots
%         % For each depot compute the evaluation
%         
%         fitness_min = inf;
%         % We are trying several different orders to find the best fitness
%         % evaluation - a little bit like RANSAC
%         for fl = 1:10
%             fitness_cur = 0;
%             
%             csi = find(population(:,i) == d);
%             csi = csi(randperm(length(csi))); % If we change the order of the customers the fitness could be better!
% 
%             while length(csi) > 1
%                 % Sort the customers that are still considered (with
%                 % respect to the distance to the first customer
%                 [D_sorted, Icurrent] = sort(D(csi(1),csi), 2, 'ascend');
%                 customers_current = customers(csi,:);
% 
%                 closest = Icurrent(1, 2); % closest customer to the first one
% 
%                 dst = sum((customers_current(1,1:2) - customers_current(closest,1:2)).^2, 2);
%                 fitness_cur = fitness_cur + dst;
% 
%                 % Remove the already used costomer
%                 csi(1) = [];
%             end
%             
%             if fitness_cur < fitness_min
%                 fitness_min = fitness_cur;
%             end
%         end
%         
%         fitness(i) = fitness(i) + fitness_min;
%     end
% end


%% No. 2 EDIT - Smarter pairing
% In the original method 2 we can easily pair more than two customers to
% the same one, but we do not want that! We want to pair only two customers
% with each customer. I.e. when we pair two customers to a customer, we
% will remove it from further consideration.
%
% Note: It is probably a little bit of a overkill because the original
% actually takes much less time and even produces a bit nicer solutions.
% Anyway I like this one, however there is probably an error somewhere
% because we always get one customer very far from the others.
%

% num_depots = size(depots, 1);
% for i = 1:length(fitness)
%     % For each individual compute fitness
% 
%     for d = 1:num_depots
%         % For each depot compute the evaluation
%         csi = find(population(:,i) == d);
% 
%         % Carry out several tries because the fitness depends on the order of
%         % the customers!
%         fitness_min = inf;
%         for fl = 1:10
%             fitness_cur = 0;
% 
%             csi = csi(randperm(length(csi))); % If we change the order of the customers the fitness can be better!
%             customers_current = customers(csi,:);
% 
%             % Sort the customers with respect to the distance to the current customer
%             [D_sorted, Icurrent] = sort(D(csi,csi), 2, 'ascend');
% 
%             % Indices of customers which are apired with the customers in csi
%             % Indices in D(csi,csi)!! not global!
%             paired = zeros(size(csi));
% 
%             % Find unique pairs of customers
%             for c = 1:length(csi)
%                 % For each customer find the closest available in the set
%                 if paired(c) ~= 0
%                     continue;
%                 end
% 
%                 % closest customer, which is not paired
%                 closest = 0; 
%                 for j = 2:length(csi)
%                     if paired(Icurrent(c, j)) == 0
%                         % The closest is not paired yet and is not paired
%                         % with the current custommer
%                         closest = Icurrent(c, j);
% 
%                         break;
%                     end
%                 end
% 
%                 if closest == 0
%                     % When the number of customers is odd
%                     continue;
%                 end
% 
%                 dst = sum((customers_current(1,1:2) - customers_current(closest,1:2)).^2, 2);
%                 fitness_cur = fitness_cur + dst;
% 
%                 % Set the pairing
%                 paired(closest) = c;
%                 paired(c) = closest;
%             end
% 
%             % Find connections between those pairs
%             new_order = randperm(length(csi));
%             csi = csi(new_order);
%             paired = paired(new_order);
%             customers_current = customers(csi,:);
%             [D_sorted, Icurrent] = sort(D(csi,csi), 2, 'ascend');
% 
%             for c = 1:length(csi)
%                 % For each customer find the closest available in the set
%                 if paired(c) < 0
%                     % This cusotmer already is in 2 pairs
%                     continue;
%                 end
% 
%                 % closest customer, which is not paired twice or with the current one
%                 closest = 0; 
%                 for j = 2:length(csi)
%                     if paired(Icurrent(c, j)) >= 0 && paired(Icurrent(c, j)) ~= c
%                         % The closest is not paired twice yet and is not paired
%                         % with the current custommer
%                         closest = Icurrent(c, j);
% 
%                         break;
%                     end
%                 end
% 
%                 if closest == 0
%                     % There probably is an isolated customer
%                     fitness_cur = fitness_cur + 100000;
%                     continue;
%                 end
% 
%                 dst = sum((customers_current(1,1:2) - customers_current(closest,1:2)).^2, 2);
%                 fitness_cur = fitness_cur + dst;
% 
%                 % Set the pairing
%                 if paired(closest) > 0
%                     % This is the second pair
%                     paired(closest) = -1;
%                 else
%                     paired(closest) = c;
%                 end
%                 if paired(c) > 0
%                     % This is the second pair
%                     paired(c) = -1;
%                 else
%                     paired(c) = closest;
%                 end
%             end
% 
%             
%             
%             if fitness_cur < fitness_min
%                 fitness_min = fitness_cur;
%             end
%         end % repeating end
% 
%         fitness(i) = fitness(i) + fitness_min;
%     end
% end


%% No. 3 - Number of nearest neighbors in the cluster
% Computer the number of times when the nearest neighbor (from all
% customers in the dataset) is also in the same cluster
%
% Note: Not ideal - creates isolated pairs => Taking just the nearest
% neighbors into account is not enough!

% [D_sorted, I] = sort(D, 2, 'ascend');
% 
% num_depots = size(depots, 1);
% for i = 1:length(fitness)
%     % For each individual compute fitness
%     for d = 1:num_depots
%         % For each depot compute the evaluation - for each customer find 2 closest ones from the cluster
%         csi = find(population(:,i) == d);
%         
%         % Nearest neighbors to the customers in the current cluster
%         nns = I(csi,2);
%         
%         fitness(i) = fitness(i) + sum(~ismember(nns, csi));
%     end
% end



end




