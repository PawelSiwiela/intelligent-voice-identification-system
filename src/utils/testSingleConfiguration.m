function result = testSingleConfiguration(X, Y, architecture, hidden_layers, ...
    train_func, activation_func, learning_rate, epochs, goal, ~, combination_id)
% =========================================================================
% TEST POJEDYNCZEJ KONFIGURACJI - BEZ CROSS-VALIDATION
% =========================================================================

config_start = tic;

try
    % =====================================================================
    % TWORZENIE SIECI
    % =====================================================================
    
    net = createNeuralNetwork(architecture, hidden_layers, train_func, ...
        activation_func, learning_rate, epochs, goal);
    
    % =====================================================================
    % PROSTY PODZIAŁ DANYCH 80/20
    % =====================================================================
    
    num_samples = size(X, 1);
    train_size = round(0.8 * num_samples);
    
    % Losowy podział
    indices = randperm(num_samples);
    train_idx = indices(1:train_size);
    test_idx = indices(train_size+1:end);
    
    X_train = X(train_idx, :);
    Y_train = Y(train_idx, :);
    X_test = X(test_idx, :);
    Y_test = Y(test_idx, :);
    
    % =====================================================================
    % TRENOWANIE SIECI
    % =====================================================================
    
    logDebug('🔄 Trenowanie sieci %s [%s]...', architecture, num2str(hidden_layers));
    
    train_start = tic;
    net = train(net, X_train', Y_train');
    training_time = toc(train_start);
    
    % =====================================================================
    % TESTOWANIE SIECI
    % =====================================================================
    
    Y_pred = net(X_test');
    [~, predicted_classes] = max(Y_pred, [], 1);
    [~, true_classes] = max(Y_test', [], 1);
    
    % Obliczenie accuracy
    accuracy = sum(predicted_classes == true_classes) / length(true_classes);
    
    % =====================================================================
    % METRYKI DODATKOWE
    % =====================================================================
    
    num_classes = size(Y, 2);
    precision_per_class = zeros(1, num_classes);
    recall_per_class = zeros(1, num_classes);
    
    for class = 1:num_classes
        tp = sum((predicted_classes == class) & (true_classes == class));
        fp = sum((predicted_classes == class) & (true_classes ~= class));
        fn = sum((predicted_classes ~= class) & (true_classes == class));
        
        if (tp + fp) > 0
            precision_per_class(class) = tp / (tp + fp);
        end
        
        if (tp + fn) > 0
            recall_per_class(class) = tp / (tp + fn);
        end
    end
    
    % Średnie metryki
    mean_precision = mean(precision_per_class);
    mean_recall = mean(recall_per_class);
    f1_score = 2 * (mean_precision * mean_recall) / (mean_precision + mean_recall);
    
    % =====================================================================
    % TWORZENIE STRUKTURY WYNIKÓW
    % =====================================================================
    
    result = struct();
    result.combination_id = combination_id;
    result.network_architecture = architecture;
    result.hidden_layers = hidden_layers;
    result.training_function = train_func;
    result.activation_function = activation_func;
    result.learning_rate = learning_rate;
    result.epochs = epochs;
    result.performance_goal = goal;
    
    % Główne metryki
    result.accuracy = accuracy;
    result.precision = mean_precision;
    result.recall = mean_recall;
    result.f1_score = f1_score;
    
    % Czasy
    result.training_time = training_time;
    result.total_time = toc(config_start);
    
    % Sieć
    result.network = net;
    
    % =====================================================================
    % LOGOWANIE
    % =====================================================================
    
    logDebug('✅ Test %d: %.1f%% accuracy w %.2fs - %s [%s]', ...
        combination_id, accuracy*100, result.total_time, ...
        architecture, num2str(hidden_layers));
    
catch ME
    logWarning('❌ Test %d nieudany: %s', combination_id, ME.message);
    
    % Zwrócenie pustej struktury w przypadku błędu
    result = struct();
    result.combination_id = combination_id;
    result.network_architecture = architecture;
    result.hidden_layers = hidden_layers;
    result.training_function = train_func;
    result.activation_function = activation_func;
    result.learning_rate = learning_rate;
    result.epochs = epochs;
    result.performance_goal = goal;
    result.accuracy = 0;  % Najgorszy możliwy wynik
    result.precision = 0;
    result.recall = 0;
    result.f1_score = 0;
    result.training_time = toc(config_start);
    result.total_time = toc(config_start);
    result.network = [];
    result.error_message = ME.message;
end

end