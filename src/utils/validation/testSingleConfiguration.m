function result = testSingleConfiguration(X, Y, architecture, hidden_layers, ...
    train_func, activation_func, learning_rate, epochs, goal, config, combination_id)
% =========================================================================
% TEST POJEDYNCZEJ KONFIGURACJI - Z CROSS-VALIDATION SUPPORT
% =========================================================================

config_start = tic;

try
    % =====================================================================
    % SPRAWDZENIE CZY UŻYWAĆ CV
    % =====================================================================
    
    if isfield(config, 'use_cross_validation') && config.use_cross_validation
        % =================================================================
        % CROSS-VALIDATION PATH
        % =================================================================
        logDebug('🔄 Używam %d-fold Cross-Validation...', config.cv_folds);
        
        [~, class_labels] = max(Y, [], 2);
        
        % Stratified CV partition
        if config.cv_stratified
            cvp = cvpartition(class_labels, 'KFold', config.cv_folds);
        else
            cvp = cvpartition(size(Y,1), 'KFold', config.cv_folds);
        end
        
        cv_accuracies = zeros(config.cv_folds, 1);
        cv_times = zeros(config.cv_folds, 1);
        
        for fold = 1:config.cv_folds
            fold_start = tic;
            
            try
                % Indeksy dla tego folda
                train_idx = training(cvp, fold);
                test_idx = test(cvp, fold);
                
                % Podział danych
                X_train = X(train_idx, :);
                Y_train = Y(train_idx, :);
                X_test = X(test_idx, :);
                Y_test = Y(test_idx, :);
                
                % Tworzenie i trenowanie sieci
                net = createNeuralNetwork(architecture, hidden_layers, train_func, ...
                    activation_func, learning_rate, epochs, goal);
                
                net = train(net, X_train', Y_train');
                
                % Testowanie
                Y_pred = net(X_test');
                [~, predicted_classes] = max(Y_pred, [], 1);
                [~, true_classes] = max(Y_test', [], 1);
                
                % Accuracy dla tego folda
                cv_accuracies(fold) = sum(predicted_classes == true_classes) / length(true_classes);
                cv_times(fold) = toc(fold_start);
                
                logDebug('  ✅ Fold %d: %.1f%% accuracy w %.2fs', fold, cv_accuracies(fold)*100, cv_times(fold));
                
            catch ME
                logWarning('  ❌ Fold %d nieudany: %s', fold, ME.message);
                cv_accuracies(fold) = 0;
                cv_times(fold) = toc(fold_start);
            end
        end
        
        % Obliczenie statystyk CV
        mean_accuracy = mean(cv_accuracies);
        std_accuracy = std(cv_accuracies);
        min_accuracy = min(cv_accuracies);
        max_accuracy = max(cv_accuracies);
        total_training_time = sum(cv_times);
        
        logDebug('📊 CV Wyniki: %.1f%% ±%.1f%% (min: %.1f%%, max: %.1f%%)', ...
            mean_accuracy*100, std_accuracy*100, min_accuracy*100, max_accuracy*100);
        
        % Trenowanie finalnej sieci na wszystkich danych (dla zapisania)
        final_net = createNeuralNetwork(architecture, hidden_layers, train_func, ...
            activation_func, learning_rate, epochs, goal);
        final_net = train(final_net, X', Y');
        
        % Tworzenie wyniku CV
        result = struct();
        result.combination_id = combination_id;
        result.network_architecture = architecture;
        result.hidden_layers = hidden_layers;
        result.training_function = train_func;
        result.activation_function = activation_func;
        result.learning_rate = learning_rate;
        result.epochs = epochs;
        result.performance_goal = goal;
        
        % CV STATISTICS
        result.accuracy = mean_accuracy;          % GŁÓWNA METRYKA
        result.cv_std = std_accuracy;
        result.cv_min = min_accuracy;
        result.cv_max = max_accuracy;
        result.cv_accuracies = cv_accuracies;
        result.cv_folds_used = config.cv_folds;
        
        % Pozostałe metryki (obliczone na średnią)
        result.precision = mean_accuracy;  % Uproszczenie
        result.recall = mean_accuracy;     % Uproszczenie
        result.f1_score = mean_accuracy;   % Uproszczenie
        
        result.training_time = total_training_time;
        result.total_time = toc(config_start);
        result.network = final_net;
        result.used_cv = true;
        
    else
        % =================================================================
        % SIMPLE SPLIT PATH (TWÓJ OBECNY KOD)
        % =================================================================
        
        net = createNeuralNetwork(architecture, hidden_layers, train_func, ...
            activation_func, learning_rate, epochs, goal);
        
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
        
        logDebug('🔄 Trenowanie sieci %s [%s]...', architecture, num2str(hidden_layers));
        
        train_start = tic;
        net = train(net, X_train', Y_train');
        training_time = toc(train_start);
        
        Y_pred = net(X_test');
        [~, predicted_classes] = max(Y_pred, [], 1);
        [~, true_classes] = max(Y_test', [], 1);
        
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
        result.used_cv = false;
        
    end
    
    % =====================================================================
    % LOGOWANIE WYNIKU
    % =====================================================================
    
    if result.used_cv
        logDebug('✅ Test %d (CV): %.1f%% ±%.1f%% accuracy w %.2fs - %s [%s]', ...
            combination_id, result.accuracy*100, result.cv_std*100, result.total_time, ...
            architecture, mat2str(hidden_layers));  % mat2str zamiast num2str
    else
        logDebug('✅ Test %d: %.1f%% accuracy w %.2fs - %s [%s]', ...
            combination_id, result.accuracy*100, result.total_time, ...
            architecture, mat2str(hidden_layers));  % mat2str zamiast num2str
    end
    
catch ME
    logWarning('❌ Test %d nieudany: %s', combination_id, ME.message);
    
    % Zwrócenie pustej struktury w przypadku błędu
    result = struct();
    result.combination_id = combination_id;
    result.accuracy = 0;
    result.total_time = toc(config_start);
    result.error_message = ME.message;
    result.used_cv = false;
end

end