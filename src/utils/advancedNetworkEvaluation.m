function results = advancedNetworkEvaluation(net, X, Y, labels, k_folds)
% =========================================================================
% ZAAWANSOWANA EWALUACJA SIECI Z CROSS-VALIDATION
% =========================================================================

evaluation_start = tic;

logDebug('📊 Rozpoczęcie %d-fold cross-validation', k_folds);

% =========================================================================
% INICJALIZACJA ZMIENNYCH
% =========================================================================

num_samples = size(X, 1);

% Jeśli labels jest puste, użyj liczby kolumn Y
if isempty(labels)
    num_classes = size(Y, 2);
    labels = cell(num_classes, 1);
    for i = 1:num_classes
        labels{i} = sprintf('Klasa_%d', i);
    end
else
    num_classes = length(labels);
end

% Metryki per fold
fold_accuracies = zeros(k_folds, 1);
fold_precisions = zeros(k_folds, num_classes);
fold_recalls = zeros(k_folds, num_classes);
fold_f1_scores = zeros(k_folds, num_classes);
fold_training_times = zeros(k_folds, 1);

% =========================================================================
% K-FOLD CROSS-VALIDATION
% =========================================================================

% UŻYCIE NASZEJ FUNKCJI crossvalind
cv_indices = crossvalind('Kfold', num_samples, k_folds);

for fold = 1:k_folds
    fold_start = tic;
    
    logDebug('🔄 Fold %d/%d', fold, k_folds);
    
    % Podział danych
    test_idx = (cv_indices == fold);
    train_idx = ~test_idx;
    
    X_train_fold = X(train_idx, :);
    Y_train_fold = Y(train_idx, :);
    X_test_fold = X(test_idx, :);
    Y_test_fold = Y(test_idx, :);
    
    % Sprawdzenie czy są dane do trenowania
    if size(X_train_fold, 1) < 2 || size(X_test_fold, 1) < 1
        logWarning('⚠️ Za mało danych w fold %d - pomijam', fold);
        fold_accuracies(fold) = 0;
        continue;
    end
    
    try
        % Trenowanie sieci na fold
        train_start = tic;
        net_fold = train(net, X_train_fold', Y_train_fold');
        fold_training_times(fold) = toc(train_start);
        
        % Testowanie
        Y_pred_fold = net_fold(X_test_fold');
        [~, predicted_classes] = max(Y_pred_fold, [], 1);
        [~, true_classes] = max(Y_test_fold', [], 1);
        
        % Obliczenie accuracy dla tego fold
        fold_accuracies(fold) = sum(predicted_classes == true_classes) / length(true_classes);
        
        % Metryki per klasa dla tego fold
        for class = 1:num_classes
            tp = sum((predicted_classes == class) & (true_classes == class));
            fp = sum((predicted_classes == class) & (true_classes ~= class));
            fn = sum((predicted_classes ~= class) & (true_classes == class));
            
            % Precision = TP / (TP + FP)
            fold_precisions(fold, class) = tp / max(tp + fp, 1);
            
            % Recall = TP / (TP + FN)
            fold_recalls(fold, class) = tp / max(tp + fn, 1);
            
            % F1 Score
            prec = fold_precisions(fold, class);
            rec = fold_recalls(fold, class);
            fold_f1_scores(fold, class) = 2 * prec * rec / max(prec + rec, 1e-10);
        end
        
    catch ME
        logWarning('⚠️ Błąd trenowania fold %d: %s', fold, ME.message);
        fold_accuracies(fold) = 0;
        fold_training_times(fold) = 0;
    end
    
    fold_time = toc(fold_start);
    logDebug('   ✅ Fold %d: accuracy=%.2f%%, time=%.2f s', ...
        fold, fold_accuracies(fold)*100, fold_time);
end

% =========================================================================
% AGREGACJA WYNIKÓW
% =========================================================================

results = struct();

% Podstawowe metryki
results.mean_accuracy = mean(fold_accuracies);
results.std_accuracy = std(fold_accuracies);
results.min_accuracy = min(fold_accuracies);
results.max_accuracy = max(fold_accuracies);

% Metryki per klasa (średnie z folds)
results.mean_precision_per_class = mean(fold_precisions, 1);
results.mean_recall_per_class = mean(fold_recalls, 1);
results.mean_f1_per_class = mean(fold_f1_scores, 1);

% Macro-averaged metryki
results.macro_precision = mean(results.mean_precision_per_class);
results.macro_recall = mean(results.mean_recall_per_class);
results.macro_f1 = mean(results.mean_f1_per_class);

% Czasy
results.mean_training_time = mean(fold_training_times);
results.total_evaluation_time = toc(evaluation_start);

% Szczegółowe dane
results.fold_accuracies = fold_accuracies;

logSuccess('🎯 Cross-validation zakończona: %.2f%% (±%.2f%%)', ...
    results.mean_accuracy*100, results.std_accuracy*100);

logInfo('⏱️ Średni czas trenowania fold: %.2f s', results.mean_training_time);
logInfo('⏱️ Całkowity czas ewaluacji: %.2f s', results.total_evaluation_time);

end