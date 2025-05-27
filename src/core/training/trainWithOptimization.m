% Aktualizacja src/core/training/trainWithOptimization.m (nowa nazwa)
function [best_net, best_params, results] = trainWithOptimization(X, Y, labels, optimization_method)
% =========================================================================
% TRENOWANIE SIECI Z WYBOREM METODY OPTYMALIZACJI
% =========================================================================

if nargin < 4
    optimization_method = 'grid_search'; % Domyślnie Grid Search
end

logInfo('🔍 Rozpoczęcie trenowania z optymalizacją: %s', optimization_method);

% Rozpoczęcie pomiaru czasu
optimization_start = tic;

% Wywołanie kontrolera optymalizacji
[best_net, best_params, results] = optimizationController(X, Y, labels, optimization_method);

optimization_time = toc(optimization_start);

% Wyświetlenie podsumowania
logSuccess('⚡ Optymalizacja %s zakończona w %.1f s (%.1f min)', ...
    optimization_method, optimization_time, optimization_time/60);

% Zapisanie wyników
saveOptimizationResults(results, best_params, best_net, optimization_method, optimization_time);

% Utworzenie raportu
createOptimizationReport(results, best_params, optimization_method);

end