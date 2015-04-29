function [ customers, depots, loads, durations, num_vehicles ] = loadDataset( filename )
% Loads the instances (customers and depots) from the given file
% Output:
%   customers = nx3 matrix
%   depots = mx2 matrix
%   loads = kx1 vector
%   durations = kx1 vector
%   num_vehicles = number

fileID = fopen(filename, 'r');

%% First line - 4 numbers
% type m n t
% m: number of vehicles
% n: number of customers
% t: number of depots (MDVRP)
row1 = num2cell(fscanf(fileID, '%d %d %d %d\n', [1 4]));
[type, num_vehicles, n, t] = deal(row1{:});

% We only want MDVRP
if type ~= 2
    disp('loadDataset(): This is not a MDVRP !!');
    return
end


%% Max load of a vehicle from each depot (should be the same for all)
loads = fscanf(fileID, '%d', [2 t])';
durations = loads(:,1);
durations(durations == 0) = inf;
loads = loads(:,2);


%% Customers' positions
% x y q
% x: x coordinate
% y: y coordinate
% q: demand
fscanf(fileID, '\n');
customers = zeros(n, 3);
for i = 1:n
    % I need to read the customers like this because the length of the line
    % can differ from file to file
    tline = fgetl(fileID);
    l = strsplit(strtrim(tline), ' ');
    customers(i, :) = [str2num(l{2}) str2num(l{3}) str2num(l{5})];
end


%% Depots' positions
% x y
% x: x coordinate
% y: y coordinate
depots = fscanf(fileID, '%f', [7 t])';
depots = depots(:, 2:3);


end

