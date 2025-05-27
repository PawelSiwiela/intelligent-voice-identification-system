function [best_net, best_params, grid_results] = trainNeuralNetworkOptimized(X, Y, labels)
% =========================================================================
% ZOPTYMALIZOWANE TRENOWANIE SIECI Z GRID SEARCH
% =========================================================================

% Rozpoczęcie pomiaru całkowitego czasu
total_start_time = tic;

logInfo('🔍 GRID SEARCH - OPTYMALIZACJA SIECI NEURONOWEJ');
logInfo('================================================');

% =========================================================================
% WCZYTANIE KONFIGURACJI
% =========================================================================

% Wczytanie domyślnej konfiguracji grid search
config = gridSearchConfig();

% Wyświetlenie informacji o konfiguracji
displayGridSearchConfig(config, X, Y, labels);

% =========================================================================
% PRZYGOTOWANIE DANYCH
% =========================================================================

data_prep_start = tic;

[num_samples, num_features] = size(X);
num_classes = size(Y, 2);

% Walidacja danych
validateInputData(X, Y, labels);

data_prep_time = toc(data_prep_start);
logInfo('⏱️ Przygotowanie danych: %.2f s', data_prep_time);

% =========================================================================
% INICJALIZACJA GRID SEARCH
% =========================================================================

% Obliczenie total combinations
total_combinations = calculateTotalCombinations(config);
logInfo('📊 Kombinacji do przetestowania: %d (max: %d)', ...
    total_combinations, config.max_combinations);

% Inicjalizacja wyników
grid_results = [];
best_performance = 0;
best_net = [];
best_params = struct();
current_combination = 0;

% Progress tracking
progress_interval = max(1, floor(min(total_combinations, config.max_combinations) / 20));

% =========================================================================
% GŁÓWNA PĘTLA GRID SEARCH
% =========================================================================

grid_search_start = tic;

logInfo('🚀 Rozpoczęcie Grid Search...');
logInfo('');

for arch_idx = 1:length(config.network_architectures)
    architecture = config.network_architectures{arch_idx};
    
    for hidden_idx = 1:length(config.hidden_layers_options)
        hidden_layers = config.hidden_layers_options{hidden_idx};
        
        for train_idx = 1:length(config.training_functions)
            train_func = config.training_functions{train_idx};
            
            for act_idx = 1:length(config.activation_functions)
                activation_func = config.activation_functions{act_idx};
                
                for lr_idx = 1:length(config.learning_rates)
                    learning_rate = config.learning_rates(lr_idx);
                    
                    for epoch_idx = 1:length(config.epochs_options)
                        epochs = config.epochs_options(epoch_idx);
                        
                        for goal_idx = 1:length(config.performance_goals)
                            goal = config.performance_goals(goal_idx);
                            
                            current_combination = current_combination + 1;
                            
                            % Limit bezpieczeństwa
                            if current_combination > config.max_combinations
                                logWarning('⚠️ Osiągnięto limit %d kombinacji', config.max_combinations);
                                break;
                            end
                            
                            % Progress report
                            if mod(current_combination, progress_interval) == 0 || current_combination == 1
                                reportProgress(current_combination, min(total_combinations, config.max_combinations), grid_search_start);
                            end
                            
                            % Test pojedynczej konfiguracji
                            try
                                config_result = testSingleConfiguration( ...
                                    X, Y, architecture, hidden_layers, train_func, ...
                                    activation_func, learning_rate, epochs, goal, ...
                                    [], current_combination);
                                
                                grid_results = [grid_results; config_result];
                                
                                % Sprawdzenie czy to najlepszy wynik
                                if config_result.accuracy > best_performance
                                    best_performance = config_result.accuracy;
                                    best_net = config_result.network;
                                    best_params = config_result;
                                    
                                    logSuccess('🏆 NOWY REKORD! %.1f%% (arch=%s, layers=[%s], %s)', ...
                                        best_performance*100, architecture, num2str(hidden_layers), train_func);
                                end
                                
                            catch ME
                                logWarning('⚠️ Błąd konfiguracji %d: %s', current_combination, ME.message);
                                continue;
                            end
                        end
                        if current_combination > config.max_combinations; break; end
                    end
                    if current_combination > config.max_combinations; break; end
                end
                if current_combination > config.max_combinations; break; end
            end
            if current_combination > config.max_combinations; break; end
        end
        if current_combination > config.max_combinations; break; end
    end
    if current_combination > config.max_combinations; break; end
end

% =========================================================================
% PODSUMOWANIE I RAPORT
% =========================================================================

total_time = toc(total_start_time);
grid_search_time = toc(grid_search_start);

% Wyświetlenie podsumowania
logInfo('');
logSuccess('🎯 GRID SEARCH ZAKOŃCZONY!');
logInfo('==========================');
logInfo('⏱️ Całkowity czas: %.1f s (%.1f min)', total_time, total_time/60);
logInfo('🔍 Czas grid search: %.1f s (%.1f min)', grid_search_time, grid_search_time/60);
logInfo('🧪 Przetestowano: %d kombinacji', length(grid_results));
logSuccess('🏆 Najlepsza dokładność: %.2f%%', best_performance*100);

% Wyświetlenie najlepszej konfiguracji
displayBestConfiguration(best_params);

% Zapisanie wyników
saveGridSearchResults(grid_results, best_params, best_net, config, total_time);

% Utworzenie szczegółowego raportu
createGridSearchReport(grid_results, best_params, labels);

end