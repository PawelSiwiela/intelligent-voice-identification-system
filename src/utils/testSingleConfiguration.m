function result = testSingleConfiguration(X, Y, architecture, hidden_layers, train_func, activation_func, learning_rate, epochs, goal, cv_folds, combination_id)
% =========================================================================
% TESTOWANIE POJEDYNCZEJ KONFIGURACJI SIECI
% =========================================================================

config_start = tic;

try
    % Utworzenie sieci
    net = createNeuralNetwork(architecture, hidden_layers, ...
        'training_function', train_func, ...
        'activation_function', activation_func, ...
        'learning_rate', learning_rate);
    
    % Ustawienie parametrów trenowania
    net.trainParam.epochs = epochs;
    net.trainParam.goal = goal;
    net.trainParam.showWindow = false;
    net.trainParam.showCommandLine = false;
    
    % Cross-validation
    evaluation_results = advancedNetworkEvaluation(net, X, Y, {}, cv_folds);
    
    % Przygotowanie wyniku
    result = struct();
    result.combination_id = combination_id;
    result.architecture = architecture;
    result.hidden_layers = hidden_layers;
    result.training_function = train_func;
    result.activation_function = activation_func;
    result.learning_rate = learning_rate;
    result.epochs = epochs;
    result.goal = goal;
    
    % BEZPIECZNE POBIERANIE WYNIKÓW
    if isstruct(evaluation_results) && isfield(evaluation_results, 'mean_accuracy')
        result.cv_performance = evaluation_results.mean_accuracy;
    else
        result.cv_performance = 0;
        logWarning('⚠️ Brak wyników accuracy - ustawiono 0');
    end
    
    if isstruct(evaluation_results) && isfield(evaluation_results, 'std_accuracy')
        result.cv_std = evaluation_results.std_accuracy;
    else
        result.cv_std = 0;
    end
    
    result.training_time = toc(config_start);
    result.network = net;
    
    logDebug('✅ Test %d: %.2f%% (±%.2f%%) w %.2fs - %s [%s]', ...
        combination_id, result.cv_performance*100, result.cv_std*100, ...
        result.training_time, architecture, num2str(hidden_layers));
    
catch ME
    logWarning('❌ Test %d nieudany: %s', combination_id, ME.message);
    
    % Zwrócenie pustej struktury w przypadku błędu
    result = struct();
    result.combination_id = combination_id;
    result.architecture = architecture;
    result.hidden_layers = hidden_layers;
    result.training_function = train_func;
    result.activation_function = activation_func;
    result.learning_rate = learning_rate;
    result.epochs = epochs;
    result.goal = goal;
    result.cv_performance = 0;  % Najgorszy możliwy wynik
    result.cv_std = 0;
    result.training_time = toc(config_start);
    result.network = [];
    result.error_message = ME.message;
end

end