function lng = routeLength( customers, depot, route )
% Computes the length (duration) of the given route

lng = 0;

% Distance to the depot from the first and last customer
lng = lng + (sum((customers(route(1),1:2) - depot).^2))^0.5 + (sum((customers(route(end),1:2) - depot).^2))^0.5;

% Distance between customers
for i = 1:length(route)-1
    lng = lng + (sum((customers(route(i),1:2) - customers(route(i+1),1:2)).^2))^0.5;
end


end

