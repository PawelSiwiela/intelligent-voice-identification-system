function [best_net, best_params, results] = trainWithOptimization(X, Y, labels, optimization_method)
% =========================================================================
% TRENOWANIE SIECI Z RANDOM SEARCH - UPROSZCZONA WERSJA
% =========================================================================

if nargin < 4
    optimization_method = 'random_search'; % Jedyna dostępna metoda
end

logInfo('🔍 Rozpoczęcie trenowania z Random Search');

% Rozpoczęcie pomiaru czasu
optimization_start = tic;

% Bezpośrednie wywołanie Random Search
config = randomSearchConfig();
[results, best_net] = randomSearchOptimizer(X, Y, labels, config);
best_params = results.best_params;

optimization_time = toc(optimization_start);

% Wyświetlenie podsumowania
logSuccess('⚡ Random Search zakończony w %.1f s (%.1f min)', ...
    optimization_time, optimization_time/60);

if isfield(results, 'best_accuracy')
    logSuccess('🏆 Najlepsza accuracy: %.1f%%', results.best_accuracy*100);
end

end