% src/core/optimization/optimizationController.m
function [best_model, best_params, results] = optimizationController(X, Y, labels, method, custom_config)

if nargin < 5, custom_config = []; end

logInfo('🚀 Rozpoczęcie optymalizacji metodą: %s', upper(method));

switch lower(method)
    case 'grid_search'
        [best_model, best_params, results] = gridSearchOptimizer(X, Y, labels, custom_config);
        
    case 'random_search'
        [best_model, best_params, results] = randomSearchOptimizer(X, Y, labels, custom_config);
        
    case 'bayesian'
        logWarning('⚠️ Bayesian Optimization jeszcze nie zaimplementowana - używam Grid Search');
        [best_model, best_params, results] = gridSearchOptimizer(X, Y, labels, custom_config);
        
    case 'genetic'
        logWarning('⚠️ Genetic Algorithm jeszcze nie zaimplementowany - używam Grid Search');
        [best_model, best_params, results] = gridSearchOptimizer(X, Y, labels, custom_config);
        
    otherwise
        error('Nieznana metoda: %s', method);
end

logSuccess('✅ Optymalizacja zakończona! Accuracy: %.2f%%', best_params.accuracy * 100);
end