% Nowy plik: src/core/optimization/gridSearchOptimizer.m
function [best_model, best_params, results] = gridSearchOptimizer(X, Y, labels, custom_config)
% =========================================================================
% OPTYMALIZATOR GRID SEARCH - SYSTEMATYCZNE PRZESZUKIWANIE
% =========================================================================

% Wczytanie konfiguracji
if isempty(custom_config)
    config = gridSearchConfig();
else
    config = custom_config;
end

logInfo('🔍 Grid Search: testowanie wszystkich kombinacji systematycznie');
displayGridSearchConfig(config, X, Y, labels);

% Przygotowanie danych
[num_samples, num_features] = size(X);
num_classes = size(Y, 2);
validateInputData(X, Y, labels);

% Obliczenie całkowitej liczby kombinacji
total_combinations = calculateTotalCombinations(config);
logInfo('🎯 Testowanie %d kombinacji parametrów', total_combinations);

% =========================================================================
% 🆕 DODAJ TE LINIE - DEFINICJA progress_interval
% =========================================================================
grid_search_start = tic;
progress_interval = max(1, floor(total_combinations / 20)); % Progress co 5%
logInfo('📊 Będę raportować postęp co %d testów', progress_interval);

% Inicjalizacja
grid_results = [];
best_performance = 0;
best_net = [];
best_params = struct();
current_combination = 0;

% === GŁÓWNA PĘTLA GRID SEARCH ===
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
                            
                            % ✅ TERAZ progress_interval JUŻ JEST ZDEFINIOWANY!
                            % Progress report
                            if mod(current_combination, progress_interval) == 0 || current_combination == 1
                                elapsed = toc(grid_search_start);
                                remaining = (elapsed / current_combination) * (total_combinations - current_combination);
                                logInfo('⏳ Progress: %d/%d (%.1f%%) | Czas: %.1fs | Pozostało: ~%.1fs', ...
                                    current_combination, total_combinations, ...
                                    100*current_combination/total_combinations, elapsed, remaining);
                            end
                            
                            % Test pojedynczej konfiguracji
                            try
                                % POPRAWIONE WYWOŁANIE - PRZEKAŻ config
                                test_result = testSingleConfiguration(X, Y, ...
                                    architecture, hidden_layers, train_func, activation_func, ...
                                    learning_rate, epochs, goal, config, current_combination);  % DODANO config!
                                
                                % Sprawdzenie czy test_result ma wymagane pola
                                if ~isfield(test_result, 'accuracy')
                                    logWarning('⚠️ test_result nie zawiera pola accuracy dla kombinacji %d', current_combination);
                                    continue;
                                end
                                
                                grid_results = [grid_results; test_result];
                                
                                % Sprawdzenie czy to najlepszy wynik
                                if test_result.accuracy > best_performance
                                    best_performance = test_result.accuracy;
                                    best_net = test_result.network;
                                    best_params = test_result;
                                    
                                    logSuccess('🏆 NOWY REKORD! %.1f%% (kombinacja %d)', ...
                                        best_performance*100, current_combination);
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

% Zwracanie wyników
best_model = best_net;
results = struct();
results.grid_results = grid_results;
results.total_time = toc(grid_search_start);
results.best_accuracy = best_performance;
results.total_combinations = current_combination;

logSuccess('⚡ Grid Search zakończony! Przetestowano %d kombinacji w %.1fs', ...
    current_combination, results.total_time);

% =========================================================================
% WYŚWIETLENIE I ZAPIS WYNIKÓW
% =========================================================================

% Wyświetlenie najlepszej konfiguracji
if ~isempty(best_params)
    displayBestConfiguration(best_params);
else
    logWarning('⚠️ Nie znaleziono żadnej działającej konfiguracji!');
end

% Zapisanie wyników do pliku
if config.save_results && ~isempty(grid_results)
    try
        saveGridSearchResults(grid_results, best_params, best_net, 'grid_search', results.total_time);
    catch ME
        logWarning('⚠️ Błąd zapisu wyników: %s', ME.message);
    end
end

% Utworzenie raportu
if ~isempty(grid_results)
    try
        createGridSearchReport(grid_results, best_params, 'grid_search');
    catch ME
        logWarning('⚠️ Błąd tworzenia raportu: %s', ME.message);
    end
end


end