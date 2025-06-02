function [best_net, best_tr, results] = voiceRecognition(config)
% VOICERECOGNITION Główna funkcja do rozpoznawania głosu i porównywania sieci neuronowych
%
% Składnia:
%   [best_net, best_tr, results] = voiceRecognition(config)
%
% Argumenty:
%   config - struktura konfiguracyjna zawierająca:
%     .noise_level - poziom szumu (domyślnie 0.1)
%     .num_samples - liczba próbek na kategorię (domyślnie 5)
%     .use_vowels - czy używać samogłosek (domyślnie true)
%     .use_complex - czy używać komend złożonych (domyślnie true)
%     .normalize_features - czy normalizować cechy (domyślnie true)
%     .scenario - scenariusz trenowania ('vowels', 'commands', 'all', domyślnie 'all')
%     .max_trials - liczba prób w random search (domyślnie 20)
%     .golden_accuracy - próg dokładności dla "złotych parametrów" (domyślnie 0.95)
%     .show_visualizations - czy pokazywać wizualizacje (domyślnie true)
%     .early_stopping - czy zatrzymać wcześniej po znalezieniu dobrych parametrów (domyślnie true)
%     .optimization_method - metoda optymalizacji ('random' lub 'genetic', domyślnie 'random')
%     .population_size - rozmiar populacji dla algorytmu genetycznego (domyślnie 10)
%     .num_generations - liczba generacji dla algorytmu genetycznego (domyślnie 4)
%     .mutation_rate - współczynnik mutacji (domyślnie 0.2)
%     .crossover_rate - współczynnik krzyżowania (domyślnie 0.8)
%     .elite_count - liczba osobników elitarnych (domyślnie 2)
%     .selection_method - metoda selekcji ('tournament' lub 'roulette', domyślnie 'tournament')
%     .tournament_size - rozmiar turnieju (domyślnie 3)
%
% Zwraca:
%   best_net - najlepsza wytrenowana sieć neuronowa
%   best_tr - dane z procesu treningu najlepszej sieci
%   results - wyniki oceny sieci i porównania

% =========================================================================
% INICJALIZACJA I USTAWIENIA DOMYŚLNE
% =========================================================================

% Ustaw globalną konfigurację dla systemu logowania
global CURRENT_CONFIG;
CURRENT_CONFIG = config;

% Parametry domyślne
if nargin < 1
    config = struct();
end

% Parametry podstawowe
default_config = struct(...
    'noise_level', 0.1, ...
    'num_samples', 5, ...
    'use_vowels', true, ...
    'use_complex', true, ...
    'normalize_features', true, ...
    'scenario', 'all', ...
    'max_trials', 20, ...
    'golden_accuracy', 0.95, ...
    'show_visualizations', true, ...
    'early_stopping', true, ...
    'optimization_method', 'random');

% Parametry algorytmu genetycznego
genetic_config = struct(...
    'population_size', 10, ...
    'num_generations', 4, ...
    'mutation_rate', 0.2, ...
    'crossover_rate', 0.8, ...
    'elite_count', 2, ...
    'selection_method', 'tournament', ...
    'tournament_size', 3);

% Uzupełnienie brakujących pól podstawowych
field_names = fieldnames(default_config);
for i = 1:length(field_names)
    field = field_names{i};
    if ~isfield(config, field)
        config.(field) = default_config.(field);
    end
end

% Uzupełnienie pól algorytmu genetycznego, jeśli wybrana jest ta metoda
if strcmp(config.optimization_method, 'genetic')
    field_names = fieldnames(genetic_config);
    for i = 1:length(field_names)
        field = field_names{i};
        if ~isfield(config, field)
            config.(field) = genetic_config.(field);
        end
    end
    
    % Informacja o konfiguracji algorytmu genetycznego
    logInfo('🧬 Optymalizacja algorytmem genetycznym: populacja=%d, generacje=%d', ...
        config.population_size, config.num_generations);
    logInfo('🧬 Parametry genetyczne: mutacja=%.2f, krzyżowanie=%.2f, elita=%d, selekcja=%s', ...
        config.mutation_rate, config.crossover_rate, config.elite_count, config.selection_method);
else
    logInfo('🔍 Optymalizacja metodą Random Search: próby=%d', config.max_trials);
end

% Dostosowanie parametrów na podstawie scenariusza
switch config.scenario
    case 'vowels'
        config.use_vowels = true;
        config.use_complex = false;
        logInfo('🔊 Scenariusz: tylko samogłoski');
    case 'commands'
        config.use_vowels = false;
        config.use_complex = true;
        logInfo('🔊 Scenariusz: tylko komendy złożone');
    case 'all'
        config.use_vowels = true;
        config.use_complex = true;
        logInfo('🔊 Scenariusz: samogłoski i komendy złożone');
    otherwise
        logWarning('⚠️ Nieznany scenariusz: %s. Używam wszystkich danych.', config.scenario);
        config.use_vowels = true;
        config.use_complex = true;
        config.scenario = 'all';
end

% Inicjalizacja struktury wyników
results = struct(...
    'config', config, ...
    'comparison', struct(), ...
    'total_time', 0);

total_time = tic;

% =========================================================================
% KROK 1: WCZYTYWANIE DANYCH
% =========================================================================

logInfo('🔄 Krok 1: Wczytywanie danych audio...');
step1_time = tic;

try
    % Mapowanie scenariusza na parametry wczytywania danych
    switch config.scenario
        case 'vowels'
            use_vowels = true;
            use_complex = false;
        case 'commands'
            use_vowels = false;
            use_complex = true;
        case 'all'
            use_vowels = true;
            use_complex = true;
        otherwise
            logWarning('⚠️ Nieznany scenariusz: %s. Używam wszystkich danych.', config.scenario);
            use_vowels = true;
            use_complex = true;
    end
    
    % Wczytanie danych audio z automatycznym preprocessingiem
    [X, Y, labels, successful_loads, failed_loads] = loadAudioData(...
        config.noise_level, config.num_samples, use_vowels, use_complex, config.normalize_features);
    
    logInfo('✅ Wczytano %d próbek (%d nieudanych) z %d kategorii', ...
        successful_loads, failed_loads, length(labels));
    
    % Sprawdzenie, czy mamy wystarczającą ilość danych
    if successful_loads < 10
        logError('❌ Za mało danych do trenowania! Wczytano tylko %d próbek.', successful_loads);
        error('Za mało danych do trenowania! Wczytano tylko %d próbek.', successful_loads);
    end
    
    results.data_loading_time = toc(step1_time);
    logSuccess('✅ Dane wczytane pomyślnie w %.2f sekund', results.data_loading_time);
catch e
    logError('❌ Błąd podczas wczytywania danych: %s', e.message);
    error('Błąd podczas wczytywania danych: %s', e.message);
end

% Zapisanie podstawowych informacji o danych
results.data_info = struct(...
    'num_samples', successful_loads, ...
    'num_failed', failed_loads, ...
    'num_features', size(X, 2), ...
    'num_classes', size(Y, 2), ...
    'class_names', {labels});

logInfo('📊 Zestawienie danych: %d próbek, %d cech, %d klas', ...
    successful_loads, size(X, 2), size(Y, 2));

% =========================================================================
% KROK 2: PORÓWNANIE SIECI NEURONOWYCH
% =========================================================================

logInfo('🧠 Krok 2: Porównanie typów sieci neuronowych...');
step2_time = tic;

% Przekazanie konfiguracji do porównania sieci
comparison_config = config; % Wszystkie parametry

logInfo('🔍 Rozpoczynam proces porównania i optymalizacji sieci...');

% Wywołanie funkcji porównującej sieci
[comparison_results] = compareNetworks(X, Y, labels, comparison_config);

% Zapisanie wyników porównania
results.comparison = comparison_results;

% Określenie zwycięskiego typu sieci
winner_type = comparison_results.comparison.winner;
logSuccess('🏆 Zwycięski typ sieci: %s (dokładność: %.2f%%)', ...
    winner_type, comparison_results.patternnet.evaluation.accuracy * 100);

if ~strcmp(winner_type, 'tie')
    winner_accuracy = comparison_results.comparison.accuracy_gain * 100;
    logSuccess('🏆 Przewaga nad drugim typem: %.2f%%', winner_accuracy);
end

% Określenie najlepszej sieci (do zwrócenia jako wynik funkcji)
if strcmp(winner_type, 'patternnet')
    best_net = comparison_results.patternnet.net;
    best_tr = comparison_results.patternnet.tr;
    best_accuracy = comparison_results.patternnet.evaluation.accuracy;
    best_params = comparison_results.patternnet.results.best_params;
else
    best_net = comparison_results.feedforwardnet.net;
    best_tr = comparison_results.feedforwardnet.tr;
    best_accuracy = comparison_results.feedforwardnet.evaluation.accuracy;
    best_params = comparison_results.feedforwardnet.results.best_params;
end

% Zapisanie czasu porównania sieci
results.comparison_time = toc(step2_time);
logInfo('⏱ Czas porównania sieci: %.2f sekund', results.comparison_time);

% =========================================================================
% KROK 3: PODSUMOWANIE WYNIKÓW
% =========================================================================

% Całkowity czas wykonania
results.total_time = toc(total_time);
logSuccess('✅ Cały proces zakończony w %.2f sekund', results.total_time);

% Podsumowanie wyników
logInfo('📋 PODSUMOWANIE PORÓWNANIA:');
logInfo('   Scenariusz: %s', config.scenario);
logInfo('   Metoda optymalizacji: %s', config.optimization_method);
logInfo('   Zwycięzca: %s (dokładność: %.2f%%)', winner_type, best_accuracy * 100);

if ~strcmp(winner_type, 'tie')
    logInfo('   Przewaga dokładności: %.2f%%', comparison_results.comparison.accuracy_gain * 100);
end

% Złote parametry dla obu sieci
if comparison_results.comparison.pattern_golden
    logSuccess('✅ Sieć patternnet osiągnęła złoty próg (≥%.0f%%)', config.golden_accuracy * 100);
end

if comparison_results.comparison.feedforward_golden
    logSuccess('✅ Sieć feedforwardnet osiągnęła złoty próg (≥%.0f%%)', config.golden_accuracy * 100);
end

% Najlepsze parametry zwycięskiej sieci
logInfo('📊 Najlepsze parametry dla %s:', winner_type);
logInfo('   Warstwy ukryte: %s', mat2str(best_params.hidden_layers));
logInfo('   Funkcja aktywacji: %s', best_params.activation_function);
logInfo('   Algorytm uczenia: %s (lr=%.5f)', best_params.training_algorithm, best_params.learning_rate);
logInfo('   Liczba epok: %d', best_params.max_epochs);

% Podsumowanie metryk dla zwycięskiej sieci
if strcmp(winner_type, 'patternnet')
    eval_results = comparison_results.patternnet.evaluation;
else
    eval_results = comparison_results.feedforwardnet.evaluation;
end

logInfo('📈 Metryki dla zwycięskiej sieci:');
logInfo('   Dokładność: %.2f%%', eval_results.accuracy * 100);
logInfo('   Precyzja: %.2f%%', eval_results.macro_precision * 100);
logInfo('   Czułość: %.2f%%', eval_results.macro_recall * 100);
logInfo('   F1-score: %.2f%%', eval_results.macro_f1 * 100);
logInfo('   Czas predykcji: %.4f s', eval_results.prediction_time);

logInfo('   Czas całkowity: %.2f sekund', results.total_time);

% Zapisanie finalnych wyników do struktury zwrotnej
results.best_accuracy = best_accuracy;
results.best_params = best_params;
results.best_network_type = winner_type;

end

function result = iif(condition, true_value, false_value)
% Prosty odpowiednik operatora ?: z innych języków
if condition
    result = true_value;
else
    result = false_value;
end
end