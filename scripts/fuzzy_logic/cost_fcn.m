function [cost] = cost_fcn(gene, nMFs, data)
%cost_fcn Determine cost of GA solution
% X - gene passed in from genetic algorithm

    actual = data.area;
    predicted = hFIS(data, gene, nMFs)';
    
    cost = sum(sqrt((actual - predicted).^2));
    if isnan(cost)
        cost = 1e5;
    end
end
