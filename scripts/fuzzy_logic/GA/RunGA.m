function out = RunGA(problem, params, nMFs)

    % Problem
    CostFunction = problem.CostFunction;
    nVar = problem.nVar;
    VarSize = [1, nVar];
    VarMin = problem.VarMin;
    VarMax = problem.VarMax;
    validate_gene = problem.Validate;

    % Params
    MaxIt = params.MaxIt;
    nPop = params.nPop;
    beta = params.beta;
    pC = params.pC;
    nC = round(pC*nPop/2)*2;
    gamma = params.gamma;
    mu = params.mu;
    default_mu = mu;
    sigma = params.sigma;
    
    % Template for Empty Individuals
    empty_individual.Position = [];
    empty_individual.Cost = [];
    
    % Best Solution Ever Found
    bestsol.Cost = inf;
    
    % Initialization
    pop = repmat(empty_individual, nPop, 1);
    for i = 1:nPop
        
        % Generate Random Solution
        pop(i).Position = unifrnd(VarMin, VarMax, VarSize);
        [pop(i).Position] = validate_gene(pop(i).Position);
        
        % Evaluate Solution
        pop(i).Cost = CostFunction(pop(i).Position);
        
        % Compare Solution to Best Solution Ever Found
        if pop(i).Cost < bestsol.Cost
            bestsol = pop(i);
        end
        
    end
    
    % Best Cost of Iterations
    bestcost = nan(MaxIt, 1);
    
    % Main Loop
    for it = 1:MaxIt
        
        % Selection Probabilities
        c = [pop.Cost];
        avgc = mean(c);
        if avgc ~= 0
            c = c/avgc;
        end
        probs = exp(-beta*c);
        
        % Initialize Offsprings Population
        popc = repmat(empty_individual, nC/2, 2);
        
        % Crossover
        for k = 1:nC/2
            
            % Select Parents
            p1 = pop(RouletteWheelSelection(probs));
            p2 = pop(RouletteWheelSelection(probs));
            
            % Perform Crossover
            [popc(k, 1).Position, popc(k, 2).Position] = ...
                UniformCrossover(p1.Position, p2.Position, gamma);
        end
        
        % Convert popc to Single-Column Matrix
        popc = popc(:);
        
        % Mutation
        parfor l = 1:nC 
            
            % Perform Mutation
            popc(l).Position = Mutate(popc(l).Position, mu, sigma);
            
            % Check for Variable Bounds
            popc(l).Position = max(popc(l).Position, VarMin);
            popc(l).Position = min(popc(l).Position, VarMax);
            popc(l).Position = validate_gene(popc(l).Position);
            
            % Evaluation
            popc(l).Cost = CostFunction(popc(l).Position);
        end

        % Compare Solution to Best Solution Ever Found
        for iii = 1:length(popc)
            if popc(iii).Cost < bestsol.Cost
                    bestsol = popc(iii);
            end
        end
        
        % Merge and Sort Populations
        pop = SortPopulation([pop; popc]);
        
        % Remove Extra Individuals
        pop = pop(1:nPop);
        
        % Update Best Cost of Iteration
        bestcost(it) = bestsol.Cost;

        % Display Itertion Information
        disp(['Iteration ' num2str(it) ': Best Cost = ' num2str(bestcost(it))]);

        % Ramp Mutation Rate if no improvement in 20 iterations
        if length(bestcost) > 100
            if bestcost(end-50) == bestcost(end)
                fprintf('exiting loop')
                break
            end
            if bestcost(end-20) == bestcost(end)
                mu = mu*2;
                fprintf('Increasing Mutation Rate...\n')
            else
                mu = default_mu;
            end
        end
    end
    
    
    % Results
    out.pop = pop;
    out.bestsol = bestsol;
    out.bestcost = bestcost;
    
end