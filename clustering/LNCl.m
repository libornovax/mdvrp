function assignments = LNCl( customers, depots, depot_capacity )
% Genetic agorithm clustering proposed by Libor Novak @CTU, 2015
%
% Fitness function consists of multiple goals, which should assure that the
% solution will be feasible
%
% Input:
%   customers = nx3 matrix
%   depots = mx2 vector
%

%% Settings
opt.pop_size = 100; % Must be even!! and even after division by 2
opt.max_evolutions = 100;
opt.prob_crossover = 0.8;
opt.prob_mutation = 0.02;
opt.tournament_size = 5;


%% Precompute the matrix of distances
% Matrix of distances
num_customers = size(customers, 1);
D = zeros(num_customers, num_customers);
for ii = 1:num_customers
    for jj = 1:num_customers
        D(ii,jj) = sum((customers(ii,1:2) - customers(jj,1:2)).^2);
    end
end



%% Initialize population
% num_customers = size(customers, 1);
num_depots = size(depots, 1);

% Randomly assign customers to depots (individuals are columns)
population = ceil(rand(num_customers, opt.pop_size) * num_depots);

% Repair - assure that the individuals satisfy max depot capaticy criterion
for i = 1:size(population, 2)
    population(:,i) = repairIndividual(population(:,i), customers, depots, depot_capacity);
end



%% Evolve the population
f = figure;
ftns = [];
for e = 1:opt.max_evolutions
    % Compute fitness' of individuals
    fitness = LNClFitness(population, customers, depots, D);
    ftns = [ftns min(fitness)];
    disp([ '[' num2str(e) '] Best fitness: ' num2str(ftns(end)) ]);
    
    % Inject new individuals - after some time to restore the population
    if mod(e, 50) == 0
        alter_population = ceil(rand(num_customers, opt.pop_size/4) * num_depots);
        for i = 1:size(alter_population, 2)
            alter_population(:,i) = repairIndividual(alter_population(:,i), customers, depots, depot_capacity);
        end
        
        [fts, idfs] = sort(fitness, 'descend');
        idfs = idfs(1:opt.pop_size/4);
        population(:,idfs) = alter_population;
    end
    
    figure(f); plot(ftns);
    pause(0.01);
    
    %% Selection
    % Select the strongest individuals by stochastic universal sampling
%     probs = (1000000 - fitness) / sum(1000000-fitness);
%     parents = randsample(opt.pop_size, opt.pop_size, true, probs); % THIS NEEDS TO BE CHANGED !!
    
    % Elitism
    parents = find(fitness == min(fitness)); % Best individual
    
    % Measure the similarity of the individuals - compute the number of similar
    % assignments in the population
    similarity = zeros(1, size(population, 2));
    for i = 1:size(population, 2)
        similarity(i) = sum(sum(population == repmat(population(:,i), 1, size(population, 2)))) / size(population, 2);
    end
    disp(['Similarity: ' num2str(mean(similarity))]);
%     similaritym = similarity - min(similarity);
    w = 1 - (similarity / max(similarity));
    
    % Tournament selection
    while length(parents) < size(population, 2)
        % Randomly select tournament_size individuals
        tournament = randsample(size(population, 2), opt.tournament_size, false);
%         tournament = randsample(size(population, 2), opt.tournament_size, true, w);
        
        % Select the best one and add to parents
        sel = find(fitness(tournament) == min(fitness(tournament)));
        parents = [parents tournament(sel(1))];
    end
    
    
    %% Crossover
    % Select population_size/2 tuples and crossover them
    % Randomly order the individuals
    parents = parents(randperm(length(parents)));
    
    % Now we can without the loss of generality crossover the two
    % subsequent individuals
    new_population = zeros(size(population));
    mutation = ones(size(population));
    for i = 1:length(parents)/2
        if rand() < opt.prob_crossover
            % One point crossover
%             anchor = ceil(rand() * (num_customers-1)) + 1; % minimum is 2
%             new_population(:,2*i) = [population(1:anchor-1,parents(2*i)); population(anchor:end,parents(2*i-1))];
%             new_population(:,2*i-1) = [population(1:anchor-1,parents(2*i-1)); population(anchor:end,parents(2*i))];
            
            % Uniform crossover - each gene switched with some probability
            swap = rand(num_customers, 1) < 0.5;
            new_population(:,2*i) = population(:,parents(2*i));
            new_population(swap,2*i) = population(swap,parents(2*i-1));
            new_population(:,2*i-1) = population(:,parents(2*i-1));
            new_population(swap,2*i-1) = population(swap,parents(2*i));
            
            % Allow mutation for one individual
            mutation(:,2*i-1) = 0; % if 0, the individual is considered for mutation
        else
            % Do not crossover - only pass to the next population
            new_population(:,2*i) = population(:,parents(2*i));
            new_population(:,2*i-1) = population(:,parents(2*i-1));
            
            % Allow mutation for both individuals
            mutation(:,2*i) = 0; % if 0, the individual is considered for mutation
            mutation(:,2*i-1) = 0; % if 0, the individual is considered for mutation
        end
    end
    
    
    %% Mutation
    % Mutate each allowed gene with probability prob_mutation
    pr_mut = rand(size(new_population)) + mutation;
    mut_genes = pr_mut < opt.prob_mutation;
%     mut_genes = pr_mut < (opt.prob_mutation + (mean(similarity)-30)/400);
    
    % Replace the mutated genes
    mutations = ceil(rand(size(new_population)) * num_depots);
    new_population(mut_genes) = mutations(mut_genes);
    
    
    %% Repair the population
    % We want to keep the requirement on depot capacity for each depot in
    % each individual, therefore after crossover and mutation we need to
    % repair the individuals that do not keep it
    for i = 1:size(new_population, 2)
        new_population(:,i) = repairIndividual(new_population(:,i), customers, depots, depot_capacity);
    end
    
    
    %% Replacement
    % Replace the whole population - generational
    population = new_population;
    
end


%% Extract the best individual from the final population
fitness = LNClFitness(population, customers, depots, D);
assignments = population(:,fitness == min(fitness));
assignments = assignments(:,1); % There can be more individuals with the min fitness

end


