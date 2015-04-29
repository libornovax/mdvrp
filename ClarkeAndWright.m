function routes = ClarkeAndWright( customers, depot, load, duration, num_vehicles )
% Solves the vehicle routing problem (VRP) given:
%   customers = nx3 matrix
%   depot = 1x2 vector
%   load = number
%   duration = number
%   num_vehicles = number


%% Compute the matrices of distances
% distances to depot
Dd = ((customers(:,1)-depot(1)).^2 + (customers(:,2)-depot(2)).^2).^0.5;
% distances between customers
D = ones(size(customers,1), size(customers,1)) + inf; 
for i = 1:size(customers,1)-1
    for j = i+1:size(customers,1)
        D(i,j) = (sum((customers(i,1:2) - customers(j,1:2)).^2))^0.5;
    end
end


%% Calculate the savings
S = zeros(size(D)) - 1;
for i = 1:size(customers,1)-1
    for j = i+1:size(customers,1)
        S(i,j) = Dd(i) + Dd(j) - D(i,j);
    end
end


%% Sort the savings in a descendng order
I = []; % rows
J = []; % columns
[sorted_values, indices] = sort(S, 2, 'descend');

% Merge the sorted rows into one long row vector (basically Merge sort)
R = [0 sorted_values(1,:)];
I = [0 ones(1, length(R)-1)];
J = [0 indices(1,:)];
for i = 2:size(sorted_values, 1)
    anchor = 1;
    for j = 1:size(sorted_values, 2)
        if sorted_values(i,j) == -1
            continue;
        end
        
        while 1
            if sorted_values(i,j) >= R(anchor+1)
                % Value is greater than the value on position anchor+1
                % put the value to anchor position
                R = [R(1:anchor) sorted_values(i,j) R(anchor+1:end)];
                I = [I(1:anchor) i I(anchor+1:end)];
                J = [J(1:anchor) indices(i,j) J(anchor+1:end)];
                anchor = anchor + 1;
                break;
            else
                anchor = anchor + 1;
                if anchor == length(R)
                    % put the value to the end
                    R = [R sorted_values(i,j)];
                    I = [I i];
                    J = [J indices(i,j)];
                    break;
                end
            end
        end
    end
end
R = R(2:end);
I = I(2:end);
J = J(2:end);


%% Build the routes
% initialize the routes
routes = cell(0);
for i = 1:size(customers,1)
    routes{i} = [i];
end

% Keep merging routes
idx = 1;
% while length(routes) > num_vehicles
while length(routes) > 1
    ri = 0;
    rj = 0;
    for i = 1:length(routes)
        % check if the route starts or ends with the I or J customer
        if routes{i}(1) == I(idx) || routes{i}(end) == I(idx)
            ri = i;
        elseif routes{i}(1) == J(idx) || routes{i}(end) == J(idx)
            rj = i;
        end
        
        if ri > 0 && rj > 0
            % I found routes that contain the customers
            break;
        end
    end
    
    if ri > 0 && rj > 0
        % I found routes that contain the customers
        
        % check if we do not exceed some restriction
        % load of a truck
%         if load < sum(customers(routes{ri},3)) + sum(customers(routes{rj},3))
%             % cannot load that much cargo
%         else
            % OK => connect the routes
            new_route = [];
            if routes{ri}(1) == I(idx)
                if routes{rj}(1) == J(idx)
                    % in both cases the nodes are in the beginning
                    new_route = [fliplr(routes{rj}) routes{ri}];
                else
                    % ri in the beggining, rj in the end
                    new_route = [routes{rj} routes{ri}];
                end
            else
                if routes{rj}(1) == J(idx)
                    % ri in the end, rj in the beginning
                    new_route = [routes{ri} routes{rj}];
                else
                    % both in the end
                    new_route = [routes{ri} fliplr(routes{rj})];
                end
            end
            
            if duration >= routeLength(customers, depot, new_route)
                % the duration does not exceed the limit
                routes{ri} = new_route;
                routes(rj) = [];
            end
%         end
    end
    
    idx = idx + 1;
    if idx > length(I)
        disp('ClarkeAndWright(): Solution is not feasible!');
        break;
    end
end

% draw routes
% figure;
% showDataset(customers, depot);
% hold on
% for i = 1:length(routes)
%     plot([depot(1); customers(routes{i}, 1); depot(1)], [depot(2); customers(routes{i}, 2); depot(2)]);
% %     sum(customers(routes{i},3))
% %     routeLength(customers, depot, routes{i})
% end




end

