% src/core/optimization/randomSearchOptimizer.m
function [best_model, best_params, results] = randomSearchOptimizer(X, Y, labels, custom_config)

if isempty(custom_config)
    config = randomSearchConfig();
else
    config = custom_config;
end

logInfo('🎲 Random Search: losowe próbkowanie %d kombinacji', config.max_iterations);

% === IMPLEMENTACJA RANDOM SEARCH ===
% Podobna logika jak Grid Search, ale z losowym wyborem parametrów

best_accuracy = 0;
best_params = struct();
results = struct();

for i = 1:config.max_iterations
    % Losowy wybór parametrów z przestrzeni
    params = sampleRandomParameters(config);
    
    % Test konfiguracji
    test_result = testSingleConfiguration(X, Y, labels, params, i, config);
    
    if test_result.accuracy > best_accuracy
        best_accuracy = test_result.accuracy;
        best_params = test_result;
        best_model = test_result.network;
        
        logSuccess('🏆 NOWY REKORD! %.1f%% (iteracja %d)', best_accuracy*100, i);
    end
    
    % Early stopping
    if config.early_stopping && shouldStop(i, best_accuracy, config)
        logInfo('🛑 Early stopping po %d iteracjach', i);
        break;
    end
end

results.best_accuracy = best_accuracy;
results.total_iterations = i;
results.method = 'random_search';

end