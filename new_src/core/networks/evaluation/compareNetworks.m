function [comparison_results] = compareNetworks(X, Y, labels, config)
% COMPARENETWORKS Porównuje sieci patternnet i feedforwardnet używając ich
% optymalnych parametrów
%
% Składnia:
%   [comparison_results] = compareNetworks(X, Y, labels, config)
%
% Argumenty:
%   X - macierz cech [próbki × cechy]
%   Y - macierz etykiet [próbki × kategorie]
%   labels - nazwy kategorii (cell array)
%   config - struktura konfiguracyjna
%
% Zwraca:
%   comparison_results - wyniki porównania sieci

% Inicjalizacja rezultatów
comparison_results = struct(...
    'patternnet', struct(), ...
    'feedforwardnet', struct(), ...
    'comparison', struct());

logInfo('🧠 Rozpoczynam porównanie sieci patternnet i feedforwardnet...');

% =========================================================================
% ETAP 1: PRZYGOTOWANIE DANYCH
% =========================================================================

% Jednokrotny podział danych dla wszystkich sieci
[X_train, Y_train, X_val, Y_val, X_test, Y_test] = splitData(X, Y, 0.2, 0.2);
logInfo('🔢 Stratyfikowany podział danych 60%%/20%%/20%% (6/2/2 próbek na kategorię)');

% Dodatkowo możesz połączyć dane treningowe i walidacyjne dla optymalizacji hiperparametrów
X_train_opt = [X_train; X_val];
Y_train_opt = [Y_train; Y_val];

% =========================================================================
% ETAP 2: OPTYMALIZACJA PARAMETRÓW SIECI PATTERNNET
% =========================================================================
logInfo('🔍 Optymalizacja parametrów dla sieci PATTERNNET');

% Konfiguracja dla optymalizatora patternnet
patternnet_config = config;
patternnet_config.network_types = {'patternnet'};
patternnet_config.X_test = X_test;  % Dodaj dane testowe do konfiguracji
patternnet_config.Y_test = Y_test;
patternnet_config.X_val = X_val;    % Dodaj dane walidacyjne do konfiguracji
patternnet_config.Y_val = Y_val;

% Wybór metody optymalizacji
if isfield(config, 'optimization_method') && strcmp(config.optimization_method, 'genetic')
    % Uruchomienie optymalizatora genetycznego dla patternnet
    [pattern_net, pattern_tr, pattern_results] = geneticOptimizer(X_train_opt, Y_train_opt, labels, patternnet_config);
else
    % Domyślnie - random search
    [pattern_net, pattern_tr, pattern_results] = randomSearchOptimizer(X_train_opt, Y_train_opt, labels, patternnet_config);
end

logSuccess('✅ Najlepsza dokładność dla patternnet: %.2f%%', pattern_results.best_accuracy * 100);

% =========================================================================
% ETAP 3: OPTYMALIZACJA PARAMETRÓW SIECI FEEDFORWARDNET
% =========================================================================
logInfo('🔍 Optymalizacja parametrów dla sieci FEEDFORWARDNET');

% Konfiguracja dla optymalizatora feedforwardnet
feedforward_config = config;
feedforward_config.network_types = {'feedforwardnet'};
feedforward_config.X_test = X_test;
feedforward_config.Y_test = Y_test;
feedforward_config.X_val = X_val;
feedforward_config.Y_val = Y_val;

% Wybór metody optymalizacji
if isfield(config, 'optimization_method') && strcmp(config.optimization_method, 'genetic')
    % Uruchomienie optymalizatora genetycznego dla feedforwardnet
    [feedforward_net, feedforward_tr, feedforward_results] = geneticOptimizer(X_train_opt, Y_train_opt, labels, feedforward_config);
else
    % Domyślnie - random search
    [feedforward_net, feedforward_tr, feedforward_results] = randomSearchOptimizer(X_train_opt, Y_train_opt, labels, feedforward_config);
end

logSuccess('✅ Najlepsza dokładność dla feedforwardnet: %.2f%%', feedforward_results.best_accuracy * 100);

% =========================================================================
% ETAP 4: SZCZEGÓŁOWA EWALUACJA OBU SIECI
% =========================================================================
logInfo('📊 Szczegółowa ewaluacja obu sieci...');

% Konfiguracja ewaluacji - bez pokazywania wizualizacji od razu
eval_config = struct(...
    'show_confusion_matrix', false, ...
    'show_roc_curve', false);

% Ewaluacja patternnet na danych testowych
eval_config.figure_title = 'Ewaluacja Patternnet';
pattern_evaluation = evaluateNetwork(pattern_net, X_test, Y_test, labels, eval_config);

% Ewaluacja feedforwardnet na danych testowych
eval_config.figure_title = 'Ewaluacja Feedforwardnet';
feedforward_evaluation = evaluateNetwork(feedforward_net, X_test, Y_test, labels, eval_config);

% Zapisanie wyników ewaluacji
comparison_results.patternnet.evaluation = pattern_evaluation;
comparison_results.feedforwardnet.evaluation = feedforward_evaluation;

% =========================================================================
% ETAP 5: ANALIZA PORÓWNAWCZA
% =========================================================================
logInfo('📊 Analiza porównawcza wyników...');

% Zapisanie szczegółowych wyników dla obu sieci
comparison_results.patternnet.net = pattern_net;
comparison_results.patternnet.tr = pattern_tr;
comparison_results.patternnet.results = pattern_results;

comparison_results.feedforwardnet.net = feedforward_net;
comparison_results.feedforwardnet.tr = feedforward_tr;
comparison_results.feedforwardnet.results = feedforward_results;

% Określenie zwycięzcy na podstawie dokładności
if pattern_evaluation.accuracy > feedforward_evaluation.accuracy
    comparison_results.comparison.winner = 'patternnet';
    comparison_results.comparison.accuracy_gain = pattern_evaluation.accuracy - feedforward_evaluation.accuracy;
elseif feedforward_evaluation.accuracy > pattern_evaluation.accuracy
    comparison_results.comparison.winner = 'feedforwardnet';
    comparison_results.comparison.accuracy_gain = feedforward_evaluation.accuracy - pattern_evaluation.accuracy;
else
    comparison_results.comparison.winner = 'tie';
    comparison_results.comparison.accuracy_gain = 0;
end

% Procentowy wzrost dokładności zwycięzcy
if ~strcmp(comparison_results.comparison.winner, 'tie')
    if strcmp(comparison_results.comparison.winner, 'patternnet')
        baseline = feedforward_evaluation.accuracy;
    else
        baseline = pattern_evaluation.accuracy;
    end
    
    if baseline > 0
        comparison_results.comparison.accuracy_gain_percent = (comparison_results.comparison.accuracy_gain / baseline) * 100;
    else
        comparison_results.comparison.accuracy_gain_percent = 0;
    end
else
    comparison_results.comparison.accuracy_gain_percent = 0;
end

% Osiągnięcie progu 95% dokładności
comparison_results.comparison.pattern_golden = false;
comparison_results.comparison.feedforward_golden = false;

if isfield(pattern_results, 'golden_found')
    comparison_results.comparison.pattern_golden = pattern_results.golden_found;
end

if isfield(feedforward_results, 'golden_found')
    comparison_results.comparison.feedforward_golden = feedforward_results.golden_found;
end

% Informacja która sieć była szybciej wytrenowana
if isfield(pattern_results, 'best_training_time') && isfield(feedforward_results, 'best_training_time')
    if pattern_results.best_training_time < feedforward_results.best_training_time
        comparison_results.comparison.faster_network = 'patternnet';
        comparison_results.comparison.time_difference = feedforward_results.best_training_time - pattern_results.best_training_time;
    else
        comparison_results.comparison.faster_network = 'feedforwardnet';
        comparison_results.comparison.time_difference = pattern_results.best_training_time - feedforward_results.best_training_time;
    end
end

% Porównanie innych metryk
comparison_results.comparison.precision_diff = pattern_evaluation.macro_precision - feedforward_evaluation.macro_precision;
comparison_results.comparison.recall_diff = pattern_evaluation.macro_recall - feedforward_evaluation.macro_recall;
comparison_results.comparison.f1_diff = pattern_evaluation.macro_f1 - feedforward_evaluation.macro_f1;
comparison_results.comparison.prediction_time_diff = pattern_evaluation.prediction_time - feedforward_evaluation.prediction_time;

% Informacja o metodzie optymalizacji
if isfield(config, 'optimization_method')
    comparison_results.comparison.optimization_method = config.optimization_method;
else
    comparison_results.comparison.optimization_method = 'random';
end

logSuccess('✅ Analiza zakończona. Zwycięzca: %s (przewaga: %.2f%%)', ...
    comparison_results.comparison.winner, ...
    comparison_results.comparison.accuracy_gain * 100);

% =========================================================================
% ETAP 6: WIZUALIZACJA WYNIKÓW (OPCJONALNIE)
% =========================================================================
if isfield(config, 'show_visualizations') && config.show_visualizations
    logInfo('📈 Generowanie wizualizacji porównawczych...');
    
    % Utworzenie bazowego katalogu dla wizualizacji
    viz_dir = fullfile('output', 'visualizations', datestr(now, 'yyyymmdd_HHMMSS'));
    if ~exist(viz_dir, 'dir')
        mkdir(viz_dir);
        logInfo('📁 Utworzono katalog dla wizualizacji: %s', viz_dir);
    end
    
    try
        % Macierze pomyłek dla obu sieci
        viz_file1 = fullfile(viz_dir, 'confusion_patternnet.png');
        viz_file2 = fullfile(viz_dir, 'confusion_feedforwardnet.png');
        
        visualizeConfusionMatrix(pattern_evaluation.confusion_matrix, labels, ...
            sprintf('Macierz konfuzji - %s', 'Patternnet'), viz_file1);
        
        visualizeConfusionMatrix(feedforward_evaluation.confusion_matrix, labels, ...
            sprintf('Macierz konfuzji - %s', 'Feedforwardnet'), viz_file2);
        
        % Wizualizacja porównania metryk
        viz_file3 = fullfile(viz_dir, 'metrics_comparison.png');
        visualizeMetricsComparison(pattern_evaluation, feedforward_evaluation, ...
            'Patternnet', 'Feedforwardnet', viz_file3);
        
        % Wizualizacja postępu treningu
        viz_file4 = fullfile(viz_dir, 'training_patternnet.png');
        viz_file5 = fullfile(viz_dir, 'training_feedforwardnet.png');
        visualizeTrainingProgress(pattern_tr, 'Patternnet', viz_file4);
        visualizeTrainingProgress(feedforward_tr, 'Feedforwardnet', viz_file5);
        
        % Wizualizacja krzywych ROC
        viz_file6 = fullfile(viz_dir, 'roc_patternnet.png');
        viz_file7 = fullfile(viz_dir, 'roc_feedforwardnet.png');
        
        % Predykcje dla krzywej ROC
        y_pred_pattern = pattern_net(X_test');
        y_pred_feedforward = feedforward_net(X_test');
        y_true = Y_test';
        
        visualizeROC(y_pred_pattern, y_true, 'Patternnet', viz_file6, labels);
        visualizeROC(y_pred_feedforward, y_true, 'Feedforwardnet', viz_file7, labels);
        
        % Wizualizacja struktury sieci
        viz_file8 = fullfile(viz_dir, 'structure_patternnet.png');
        viz_file9 = fullfile(viz_dir, 'structure_feedforwardnet.png');
        
        visualizeNetworkStructure(pattern_net, sprintf('Struktura sieci %s', 'Patternnet'), viz_file8);
        visualizeNetworkStructure(feedforward_net, sprintf('Struktura sieci %s', 'Feedforwardnet'), viz_file9);
        
        % Zapisanie informacji o metodzie optymalizacji
        optim_info_file = fullfile(viz_dir, 'optimization_info.txt');
        fid = fopen(optim_info_file, 'w');
        fprintf(fid, 'Metoda optymalizacji: %s\n', comparison_results.comparison.optimization_method);
        
        if strcmp(comparison_results.comparison.optimization_method, 'genetic')
            fprintf(fid, 'Parametry algorytmu genetycznego:\n');
            fprintf(fid, '- Rozmiar populacji: %d\n', config.population_size);
            fprintf(fid, '- Liczba generacji: %d\n', config.num_generations);
            fprintf(fid, '- Współczynnik mutacji: %.2f\n', config.mutation_rate);
            fprintf(fid, '- Współczynnik krzyżowania: %.2f\n', config.crossover_rate);
            fprintf(fid, '- Rozmiar elity: %d\n', config.elite_count);
            fprintf(fid, '- Metoda selekcji: %s\n', config.selection_method);
        else
            fprintf(fid, 'Parametry Random Search:\n');
            fprintf(fid, '- Liczba prób: %d\n', config.max_trials);
        end
        fclose(fid);
        
        logSuccess('✅ Wizualizacje wygenerowane i zapisane do: %s', viz_dir);
    catch e
        logWarning('⚠️ Problem z generowaniem lub zapisywaniem wizualizacji: %s', e.message);
        disp(e.stack);
    end
end

logSuccess('✅ Porównanie sieci zakończone.');

end