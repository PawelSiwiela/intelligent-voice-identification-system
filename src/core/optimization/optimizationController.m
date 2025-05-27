% src/core/optimization/optimizationController.m
function [best_net, best_params, results] = optimizationController(X, Y, labels, method)
% =========================================================================
% KONTROLER OPTYMALIZACJI - POPRAWIONE WYWOŁANIA
% =========================================================================

if nargin < 4
    method = 'grid_search'; % Domyślnie grid search
end

logInfo('🔍 Uruchamianie optymalizacji: %s', method);

% Load configuration and run optimization
switch lower(method)
    case 'grid_search'
        config = gridSearchConfig();
        logInfo('📊 Grid Search: systematyczne przeszukiwanie');
        [best_net, best_params, results] = gridSearchOptimizer(X, Y, labels, config);
        
    case 'random_search'
        config = randomSearchConfig();
        logInfo('🎲 Random Search: losowe przeszukiwanie');
        [best_net, best_params, results] = randomSearchOptimizer(X, Y, labels, config);
        
    case 'bayesian'
        logWarning('⚠️ Bayesian optimization - używam Grid Search jako fallback');
        config = gridSearchConfig();
        [best_net, best_params, results] = gridSearchOptimizer(X, Y, labels, config);
        
    case 'genetic'
        logWarning('⚠️ Genetic algorithm - używam Grid Search jako fallback');
        config = gridSearchConfig();
        [best_net, best_params, results] = gridSearchOptimizer(X, Y, labels, config);
        
    otherwise
        logError('❌ Nieznana metoda optymalizacji: %s', method);
        logInfo('📋 Dostępne metody: grid_search, random_search');
        
        % Fallback do grid search
        logInfo('🔄 Używam Grid Search jako fallback...');
        config = gridSearchConfig();
        [best_net, best_params, results] = gridSearchOptimizer(X, Y, labels, config);
end

logSuccess('✅ Optymalizacja %s zakończona pomyślnie', method);

end