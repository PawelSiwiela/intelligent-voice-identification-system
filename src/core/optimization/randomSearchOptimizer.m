% src/core/optimization/randomSearchOptimizer.m
function [best_model, best_params, results] = randomSearchOptimizer(X, Y, labels, custom_config)
% =========================================================================
% OPTYMALIZATOR RANDOM SEARCH - LOSOWE PRZESZUKIWANIE
% =========================================================================

% Wczytanie konfiguracji
if isempty(custom_config)
    config = randomSearchConfig();
else
    config = custom_config;
end

logInfo('🎲 Random Search: losowe próbkowanie %d kombinacji', config.max_iterations);
displayRandomSearchConfig(config, X, Y, labels);

% Przygotowanie danych
[num_samples, num_features] = size(X);
num_classes = size(Y, 2);
validateInputData(X, Y, labels);

% =========================================================================
% INICJALIZACJA RANDOM SEARCH
% =========================================================================

% Ustawienie seed dla powtarzalności
if isfield(config, 'random_seed')
    rng(config.random_seed);
    logInfo('🔢 Random seed: %d', config.random_seed);
end

random_search_start = tic;

% Inicjalizacja wyników
best_accuracy = 0;
best_model = [];
best_params = struct();
random_results = [];
iterations_without_improvement = 0;

% =========================================================================
% GŁÓWNA PĘTLA RANDOM SEARCH
% =========================================================================

for i = 1:config.max_iterations
    % Progress report co 20 iteracji
    if mod(i, 20) == 0 || i == 1
        elapsed = toc(random_search_start);
        remaining = (elapsed / i) * (config.max_iterations - i);
        logInfo('⏳ Random Search: %d/%d (%.1f%%) | Czas: %.1fs | Pozostało: ~%.1fs', ...
            i, config.max_iterations, 100*i/config.max_iterations, elapsed, remaining);
    end
    
    try
        % =====================================================================
        % LOSOWY WYBÓR PARAMETRÓW - UŻYJ NOWEJ FUNKCJI
        % =====================================================================
        
        params = sampleRandomParameters(config);
        
        % =====================================================================
        % TEST KONFIGURACJI
        % =====================================================================
        
        % POPRAWIONE WYWOŁANIE - z parametrami ze struktury
        test_result = testSingleConfiguration(X, Y, ...
            params.architecture, params.hidden_layers, params.train_func, params.activation_func, ...
            params.learning_rate, params.epochs, params.goal, [], i);
        
        % Sprawdzenie czy test_result ma wymagane pola
        if ~isfield(test_result, 'accuracy')
            logWarning('⚠️ test_result nie zawiera pola accuracy dla iteracji %d', i);
            continue;
        end
        
        random_results = [random_results; test_result];
        
        % =====================================================================
        % SPRAWDZENIE CZY TO NAJLEPSZY WYNIK
        % =====================================================================
        
        if test_result.accuracy > best_accuracy
            improvement = test_result.accuracy - best_accuracy;
            best_accuracy = test_result.accuracy;
            best_params = test_result;
            best_model = test_result.network;
            iterations_without_improvement = 0;
            
            logSuccess('🏆 NOWY REKORD! %.1f%% (+%.3f%%) - iteracja %d', ...
                best_accuracy*100, improvement*100, i);
        else
            iterations_without_improvement = iterations_without_improvement + 1;
        end
        
        % =====================================================================
        % EARLY STOPPING
        % =====================================================================
        
        if isfield(config, 'early_stopping') && config.early_stopping && ...
                isfield(config, 'patience') && iterations_without_improvement >= config.patience
            logInfo('🛑 Early stopping! Brak poprawy przez %d iteracji', config.patience);
            break;
        end
        
    catch ME
        logWarning('⚠️ Błąd iteracji %d: %s', i, ME.message);
        continue;
    end
end

% =========================================================================
% FINALIZACJA WYNIKÓW
% =========================================================================

% Zwracanie wyników
results = struct();
results.random_results = random_results;
results.total_time = toc(random_search_start);
results.best_accuracy = best_accuracy;
results.total_iterations = i;
results.iterations_without_improvement = iterations_without_improvement;
results.method = 'random_search';

logSuccess('⚡ Random Search zakończony! Przetestowano %d kombinacji w %.1fs', ...
    i, results.total_time);

% =========================================================================
% WYŚWIETLENIE I ZAPIS WYNIKÓW - UŻYJ NOWYCH FUNKCJI
% =========================================================================

% Wyświetlenie najlepszej konfiguracji
if ~isempty(best_params) && isfield(best_params, 'accuracy')
    logInfo('');
    displayBestConfiguration(best_params);
else
    logWarning('⚠️ Nie znaleziono żadnej działającej konfiguracji!');
    
    % Utwórz pustą strukturę best_params dla bezpieczeństwa
    if isempty(best_params)
        best_params = struct();
        best_params.accuracy = 0;
        best_params.network_architecture = 'brak';
        best_params.error_message = 'Wszystkie konfiguracje zakończyły się błędem';
    end
end

% Zapisanie wyników do pliku - UŻYJ NOWEJ FUNKCJI
if isfield(config, 'save_results') && config.save_results && ~isempty(random_results)
    try
        logInfo('💾 Zapisywanie wyników Random Search...');
        saveRandomSearchResults(random_results, best_params, best_model, 'random_search', results.total_time);
    catch ME
        logWarning('⚠️ Błąd zapisu wyników: %s', ME.message);
    end
end

% Utworzenie raportu - UŻYJ NOWEJ FUNKCJI
if ~isempty(random_results)
    try
        logInfo('📊 Tworzenie raportu Random Search...');
        createRandomSearchReport(random_results, best_params, 'random_search');
    catch ME
        logWarning('⚠️ Błąd tworzenia raportu: %s', ME.message);
    end
else
    logWarning('⚠️ Brak wyników do raportu');
end

end