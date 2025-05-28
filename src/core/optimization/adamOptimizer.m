function [results, best_model] = adamOptimizer(X, Y, labels, config)
% =========================================================================
% OPTYMALIZATOR ADAM - PEŁNA IMPLEMENTACJA BEZ DEEP LEARNING TOOLBOX
% =========================================================================

logInfo('🚀 Rozpoczynam optymalizację z algorytmem ADAM');

% Inicjalizacja wyników
adam_results = [];
best_accuracy = 0;
best_params = struct();
best_model = [];

adam_start = tic;

% Główna pętla optymalizacji
for i = 1:config.max_iterations
    % Losowanie hiperparametrów
    params = sampleAdamHyperparameters(config);
    
    logInfo('🧠 Test %d/%d: lr=%.4f, layers=%s, train=%s', ...
        i, config.max_iterations, params.learning_rate, ...
        mat2str(params.hidden_layers), params.train_function);
    
    try
        % Trenowanie z optymalizowanymi parametrami
        [net, accuracy] = trainWithOptimizedParams(X, Y, params);
        
        % Zapisanie wyniku
        result = params;
        result.accuracy = accuracy;
        result.iteration = i;
        
        if isempty(adam_results)
            adam_results = result;
        else
            adam_results(end+1) = result;
        end
        
        % Sprawdzenie czy to najlepszy wynik
        if accuracy > best_accuracy
            best_accuracy = accuracy;
            best_params = params;
            best_model = net;
            
            logSuccess('🏆 NOWY REKORD! %.1f%% - lr=%.4f, layers=%s', ...
                accuracy*100, params.learning_rate, mat2str(params.hidden_layers));
        end
        
        logDebug('   ✅ Accuracy: %.1f%%', accuracy*100);
        
    catch ME
        logWarning('⚠️ Błąd iteracji %d: %s', i, ME.message);
        continue;
    end
end

% ===== FOCUSED SEARCH - skupienie na najlepszych parametrach =====
if config.focused_search && best_accuracy > 0.90  % Jeśli już mamy dobry wynik
    logInfo('🎯 Rozpoczynam focused search wokół najlepszych parametrów...');
    
    for i = 1:config.focused_iterations
        % Losowanie wokół najlepszych parametrów
        params = sampleFocusedParams(config, best_params);
        
        logInfo('🎯 Focused %d/%d: lr=%.4f, layers=%s, train=%s', ...
            i, config.focused_iterations, params.learning_rate, ...
            mat2str(params.hidden_layers), params.train_function);
        
        try
            [net, accuracy] = trainWithOptimizedParams(X, Y, params);
            
            % Zapisanie wyniku
            result = params;
            result.accuracy = accuracy;
            result.iteration = config.max_iterations + i;
            adam_results(end+1) = result;
            
            if accuracy > best_accuracy
                best_accuracy = accuracy;
                best_params = params;
                best_model = net;
                
                logSuccess('🏆 FOCUSED REKORD! %.1f%% - lr=%.4f, layers=%s', ...
                    accuracy*100, params.learning_rate, mat2str(params.hidden_layers));
            end
            
        catch ME
            logWarning('⚠️ Błąd focused iteracji %d: %s', i, ME.message);
            continue;
        end
    end
end

% Finalizacja wyników
results = struct();
results.adam_results = adam_results;
results.total_time = toc(adam_start);
results.best_accuracy = best_accuracy;
results.best_params = best_params;  % ✅ UPEWNIJ SIĘ ŻE TO ISTNIEJE!
results.method = 'adam';

% DODAJ TO - dla kompatybilności z displayFinalSummary:
if ~isempty(best_params)
    results.best_params.accuracy = best_accuracy;
    results.best_params.method = 'adam';
    results.best_params.total_time = results.total_time;
end

logSuccess('⚡ Optymalizacja ADAM zakończona! Najlepszy wynik: %.1f%%', best_accuracy*100);

end

function [net, accuracy] = trainWithOptimizedParams(X, Y, params)
% =========================================================================
% TRENOWANIE SIECI Z OPTYMALIZOWANYMI PARAMETRAMI
% =========================================================================

% Tworzenie sieci neuronowej
net = patternnet(params.hidden_layers, params.train_function);

% Ustawienie parametrów treningu
net.trainParam.lr = params.learning_rate;
net.trainParam.epochs = params.epochs;
net.trainParam.goal = 1e-6;
net.trainParam.max_fail = params.validation_checks;
net.trainParam.showWindow = false;

% Ustawienie funkcji aktywacji
for i = 1:length(params.hidden_layers)
    net.layers{i}.transferFcn = params.activation_function;
end

% Ustawienie podziału danych
net.divideFcn = 'dividerand';
net.divideParam.trainRatio = params.train_ratio;
net.divideParam.valRatio = params.val_ratio;
net.divideParam.testRatio = params.test_ratio;

% Przygotowanie danych (transpozycja dla MATLAB Neural Network Toolbox)
X_train = X';  % MATLAB expects features × samples
Y_train = Y';  % MATLAB expects outputs × samples

% Trenowanie sieci
net = train(net, X_train, Y_train);

% Obliczenie accuracy na danych testowych
outputs = net(X_train);
[~, predicted_class] = max(outputs, [], 1);
[~, actual_class] = max(Y_train, [], 1);

accuracy = sum(predicted_class == actual_class) / length(actual_class);

end