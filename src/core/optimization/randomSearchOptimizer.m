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

% ===== GŁÓWNA PĘTLA RANDOM SEARCH =====
for i = 1:config.max_iterations
    % Losowanie parametrów
    params = sampleRandomParameters(config);
    
    logInfo('🧠 Test %d/%d: [%s], %s, lr=%.3f', ...
        i, config.max_iterations, mat2str(params.hidden_layers), ...
        params.train_function, params.learning_rate);
    
    try
        % Trenowanie z wylosowanymi parametrami
        [net, accuracy] = trainWithRandomParams(X, Y, params);
        
        % Zapisanie wyniku
        result = params;
        result.accuracy = accuracy;
        result.iteration = i;
        result.network = net;
        
        if isempty(random_results)
            random_results = result;
        else
            random_results(end+1) = result;
        end
        
        % Sprawdzenie czy to najlepszy wynik
        if accuracy > best_accuracy
            best_accuracy = accuracy;
            best_params = result;
            best_model = net;
            
            logSuccess('🏆 NOWY REKORD! %.1f%% - [%s], %s, lr=%.3f', ...
                accuracy*100, mat2str(params.hidden_layers), ...
                params.train_function, params.learning_rate);
        end
        
        logDebug('   ✅ Accuracy: %.1f%%', accuracy*100);
        
        % Early stopping jeśli osiągnięto cel
        if isfield(config, 'target_accuracy') && accuracy >= config.target_accuracy
            logSuccess('🎯 Osiągnięto cel %.1f%%! Zatrzymuję search.', config.target_accuracy*100);
            break;
        end
        
    catch ME
        logWarning('⚠️ Błąd iteracji %d: %s', i, ME.message);
        continue;
    end
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
% Trenowanie sieci z losowymi parametrami - BEZ PLOTÓW!

% Tworzenie sieci
net = patternnet(params.hidden_layers, params.train_function);

% ===== KLUCZOWE - WYŁĄCZENIE WSZYSTKICH PLOTÓW =====
net.trainParam.showWindow = false;        % ⚠️ NAJWAŻNIEJSZE!
net.trainParam.showCommandLine = false;   % Wyłącz output w command line
net.plotFcns = {};                        % Usuń wszystkie funkcje plotów

% Parametry treningu
net.trainParam.lr = params.learning_rate;
net.trainParam.epochs = params.epochs;

if isfield(params, 'performance_goal')
    net.trainParam.goal = params.performance_goal;
end

if isfield(params, 'validation_checks')
    net.trainParam.max_fail = params.validation_checks;
end

% Trenowanie - teraz bez plotów!
net = train(net, X', Y');

% Obliczenie accuracy
outputs = net(X');
accuracy = sum(vec2ind(outputs) == vec2ind(Y')) / size(Y, 1);

end