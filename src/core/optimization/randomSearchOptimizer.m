% src/core/optimization/randomSearchOptimizer.m
function [results, best_model] = randomSearchOptimizer(X, Y, labels, config)
% =========================================================================
% RANDOM SEARCH OPTIMIZER - PRAWDZIWY RANDOM SEARCH
% =========================================================================

if nargin < 4
    config = randomSearchConfig();
end

logInfo('🎲 Rozpoczynam Random Search z %d iteracjami', config.max_iterations);

% Inicjalizacja
random_results = [];
best_accuracy = 0;
best_params = struct();
best_model = [];
optimization_start = tic;

% Ustawienie random seed jeśli podano
if isfield(config, 'random_seed')
    rng(config.random_seed);
end

% ===== GŁÓWNA PĘTLA RANDOM SEARCH Z EARLY STOPPING I TIMEOUT =====
target_accuracy = 0.95; % 95% - próg do zatrzymania
timeout_count = 0;       % Licznik timeout'ów

for i = 1:config.max_iterations
    % Sprawdzenie timeout całkowitego czasu
    total_elapsed = toc(optimization_start);
    if isfield(config, 'max_total_time') && total_elapsed > config.max_total_time
        logWarning('⏰ TIMEOUT CAŁKOWITY! Przekroczono %d sekund. Zatrzymuję search.', config.max_total_time);
        break;
    end
    
    % Losowanie parametrów
    params = sampleRandomParameters(config);
    
    logInfo('🧠 Test %d/%d: [%s], %s, lr=%.3f', ...
        i, config.max_iterations, mat2str(params.hidden_layers), ...
        params.train_function, params.learning_rate);
    
    % ===== TRENOWANIE Z TIMEOUT =====
    iteration_start = tic;
    training_completed = false;
    
    try
        % Przekaż timeout do params jeśli dostępny
        if isfield(config, 'timeout_per_iteration')
            params.timeout_per_iteration = config.timeout_per_iteration;
        end
        
        % Trenowanie z wylosowanymi parametrami (używa zmodyfikowanej funkcji)
        iteration_start = tic;
        [net, accuracy] = trainWithRandomParams(X, Y, params);
        iteration_time = toc(iteration_start);
        
        % Sprawdź czy to był timeout
        timeout_occurred = false;
        if isfield(config, 'timeout_per_iteration') && iteration_time >= config.timeout_per_iteration
            timeout_occurred = true;
            logWarning('⏰ TIMEOUT iteracji %d (%.1fs) - parametry: [%s], %s, lr=%.3f', ...
                i, iteration_time, mat2str(params.hidden_layers), ...
                params.train_function, params.learning_rate);
        end
        
        % Zapisanie wyniku
        result = params;
        result.accuracy = accuracy;
        result.iteration = i;
        result.training_time = iteration_time;
        result.timeout = timeout_occurred;
        
        if isempty(random_results)
            random_results = result;
        else
            random_results(end+1) = result;
        end
        
        % Sprawdzenie czy to najlepszy wynik (tylko jeśli nie było timeout)
        if accuracy > best_accuracy && ~timeout_occurred
            best_accuracy = accuracy;
            best_params = result;
            best_model = net;
            
            logSuccess('🏆 NOWY REKORD! %.1f%% - [%s], %s, lr=%.3f (czas: %.1fs)', ...
                accuracy*100, mat2str(params.hidden_layers), ...
                params.train_function, params.learning_rate, iteration_time);
        end
        
        if timeout_occurred
            timeout_count = timeout_count + 1;  % DODAJ TEN LICZNIK
            logDebug('   ⏰ TIMEOUT - wynik: %.1f%% (czas: %.1fs)', accuracy*100, iteration_time);
        else
            logDebug('   ✅ Accuracy: %.1f%% (czas: %.1fs)', accuracy*100, iteration_time);
        end
        
        % ===== EARLY STOPPING - KLUCZOWA SEKCJA! =====
        if accuracy >= target_accuracy && ~timeout_occurred
            logSuccess('🎯 OSIĄGNIĘTO CEL %.1f%%! Zatrzymuję Random Search po %d iteracjach', ...
                accuracy*100, i);
            logSuccess('🚀 Znalezione GOLDEN parametry:');
            logSuccess('   🧠 Architektura: %s', mat2str(params.hidden_layers));
            logSuccess('   ⚙️ Funkcja treningu: %s', params.train_function);
            logSuccess('   📈 Learning rate: %.4f', params.learning_rate);
            logSuccess('   🔧 Aktywacja: %s', params.activation_function);
            logSuccess('   📊 Epoki: %d', params.epochs);
            
            % Zapisz natychmiast najlepsze parametry
            saveGoldenParameters(best_params, accuracy, i);
            
            break; % PRZERWIJ SEARCH!
        end
        
    catch ME
        iteration_time = toc(iteration_start);
        logWarning('⚠️ Błąd iteracji %d: %s (czas: %.1fs)', i, ME.message, iteration_time);
        
        % Zapisz błąd jako wynik z accuracy=0
        result = params;
        result.accuracy = 0;
        result.iteration = i;
        result.training_time = iteration_time;
        result.timeout = (iteration_time >= config.timeout_per_iteration);
        result.error_message = ME.message;
        
        if isempty(random_results)
            random_results = result;
        else
            random_results(end+1) = result;
        end
        
        continue;
    end
end

% Dodaj statystyki timeout'ów na końcu
if timeout_count > 0
    logInfo('⏰ Statystyki timeout:');
    logInfo('   🕐 Liczba timeout: %d/%d (%.1f%%)', timeout_count, i, 100*timeout_count/i);
    logInfo('   ⏱️ Timeout per iteracja: %d sekund', config.timeout_per_iteration);
end

% Finalizacja
results = struct();
results.random_results = random_results;
results.total_time = toc(optimization_start);
results.best_accuracy = best_accuracy;
results.best_params = best_params;
results.method = 'random_search';

logSuccess('⚡ Random Search zakończony! Najlepszy wynik: %.1f%%', best_accuracy*100);

% Zapisanie wyników
if config.save_results && ~isempty(random_results)
    saveRandomSearchResults(random_results, best_params, best_model, 'random_search', results.total_time);
end

% Tworzenie raportu
if ~isempty(random_results)
    createRandomSearchReport(random_results, best_params, 'random_search');
end

end

function [net, accuracy] = trainWithRandomParams(X, Y, params)
% Trenowanie sieci z losowymi parametrami - BEZ PLOTÓW + Z TIMEOUT!

% Tworzenie sieci
net = patternnet(params.hidden_layers, params.train_function);

% Parametry treningu
net.trainParam.lr = params.learning_rate;
net.trainParam.epochs = params.epochs;

if isfield(params, 'performance_goal')
    net.trainParam.goal = params.performance_goal;
end

if isfield(params, 'validation_checks')
    net.trainParam.max_fail = params.validation_checks;
end

% ===== TRENOWANIE Z KONTROLĄ CZASU =====
training_start = tic;
max_training_time = 45; % 45 sekund domyślny timeout

% Sprawdź czy params ma timeout (jeśli będzie przekazywany z config)
if isfield(params, 'timeout_per_iteration')
    max_training_time = params.timeout_per_iteration;
end

try
    % Trenowanie sieci
    net = train(net, X', Y');
    
    training_time = toc(training_start);
    
    % Sprawdzenie czy trenowanie nie trwało za długo
    if training_time > max_training_time * 1.2  % 20% tolerancja
        logWarning('⚠️ Trenowanie trwało długo: %.1fs (limit: %ds)', ...
            training_time, max_training_time);
    end
    
catch ME
    training_time = toc(training_start);
    
    % Sprawdź czy to może być timeout
    if training_time > max_training_time
        logWarning('⏰ Możliwy timeout po %.1fs - parametry: [%s], %s', ...
            training_time, mat2str(params.hidden_layers), params.train_function);
    end
    
    % Re-throw error
    rethrow(ME);
end

% Obliczenie accuracy
outputs = net(X');
accuracy = sum(vec2ind(outputs) == vec2ind(Y')) / size(Y, 1);

end