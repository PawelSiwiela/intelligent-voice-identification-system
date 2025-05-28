function voiceRecognition()

% Rozpoczęcie pomiaru całkowitego czasu
total_start = tic;

% =========================================================================
% KONFIGURACJA PARAMETRÓW SYSTEMU
% =========================================================================

% Parametry przetwarzania audio
noise_level = 0.1;         % Poziom szumu dodawanego do sygnału (0.0-1.0)
num_samples = 10;          % Liczba próbek audio na każdą kategorię

% Parametry kategorii danych
use_vowels = true;         % Czy wczytywać samogłoski (a, e, i)
use_complex = true;        % Czy wczytywać komendy złożone (pary słów)

% Parametry normalizacji
normalize_features = true; % Czy normalizować cechy przed trenowaniem

logInfo('🎵 SYSTEM ROZPOZNAWANIA GŁOSU - ROZPOCZĘCIE');
logInfo('==========================================');
logInfo('');

% =========================================================================
% KROK 1: WCZYTYWANIE I PRZETWARZANIE DANYCH AUDIO
% =========================================================================
logInfo('=== KROK 1: Wczytywanie danych audio ===');
loading_start = tic;

% Wyświetlenie aktualnej konfiguracji
logInfo('📋 Konfiguracja systemu:');
logInfo('   • Samogłoski: %s', yesno(use_vowels));
logInfo('   • Komendy złożone: %s', yesno(use_complex));
logInfo('   • Próbek na kategorię: %d', num_samples);
logInfo('   • Poziom szumu: %.1f', noise_level);
logInfo('   • Normalizacja cech: %s', yesno(normalize_features));

% Generowanie nazwy pliku na podstawie aktualnej konfiguracji
config_string = generateConfigString(use_vowels, use_complex);

% Określenie ścieżki do pliku z danymi
if normalize_features
    data_file = fullfile('output', 'preprocessed', sprintf('loaded_audio_data_%s_normalized.mat', config_string));
else
    data_file = fullfile('output', 'preprocessed', sprintf('loaded_audio_data_%s_raw.mat', config_string));
end

% Sprawdzenie czy istnieją już przetworzone dane
data_exists = exist(data_file, 'file');

if data_exists
    logSuccess('✅ Znaleziono plik z danymi: %s', data_file);
    load_existing = true;
else
    logWarning('⚠️ Nie znaleziono pliku z danymi: %s', data_file);
    logInfo('📦 Rozpoczynam przetwarzanie danych od nowa...\n');
    load_existing = false;
end

% Wczytanie istniejących danych i sprawdzenie kompatybilności
if load_existing
    logInfo('📂 Wczytywanie zapisanych danych z %s...', data_file);
    
    loaded_data = load(data_file);
    
    % Weryfikacja zgodności konfiguracji
    config_compatible = validateConfiguration(loaded_data, use_vowels, use_complex);
    
    if config_compatible
        % Wczytanie danych z pliku
        X = loaded_data.X;
        Y = loaded_data.Y;
        labels = loaded_data.labels;
        successful_loads = loaded_data.successful_loads;
        failed_loads = loaded_data.failed_loads;
        
        % Wyświetlenie informacji o wczytanych danych
        displayLoadedDataInfo(X, Y, labels, loaded_data);
    else
        load_existing = false; % Wymuś przetwarzanie od nowa
    end
end

% Przetwarzanie danych od nowa (jeśli potrzeba)
if ~load_existing
    logInfo('🔄 Przetwarzanie danych od nowa...');
    
    try
        [X, Y, labels, successful_loads, failed_loads] = loadAudioData(...
            noise_level, num_samples, use_vowels, use_complex, normalize_features);
        
        % Sprawdzenie czy dane zostały wczytane pomyślnie
        if isempty(X)
            logError('❌ Nie udało się wczytać danych lub proces został zatrzymany.');
            return;
        end
        
        logSuccess('✅ Przetwarzanie zakończone pomyślnie!');
        
    catch ME
        if contains(ME.message, 'zatrzymane')
            logWarning('🛑 Proces został zatrzymany przez użytkownika.');
            return;
        else
            rethrow(ME);
        end
    end
end

% Podsumowanie wczytywania danych
loading_time = toc(loading_start);
displayLoadingSummary(loading_time, successful_loads, failed_loads);

% =========================================================================
% OPTYMALIZACJA HIPERPARAMETRÓW
% =========================================================================

logInfo('🔍 Rozpoczynam optymalizację hiperparametrów...');

% Wybór metody optymalizacji
selected_method = 'random_search';

logInfo('🎲 Metoda optymalizacji: RANDOM SEARCH');
logInfo('💎 Cel: znalezienie Golden Parameters (95%+)');

% Czas rozpoczęcia optymalizacji
optimization_start = tic;

% Pobieranie konfiguracji Random Search
config = randomSearchConfig();

% Wyświetlenie konfiguracji
displayRandomSearchConfig(config, X, Y, labels);

% Pobranie wyników optymalizacji
[results, best_model] = randomSearchOptimizer(X, Y, labels, config);

% Czas zakończenia optymalizacji
optimization_time = toc(optimization_start);

logSuccess('⚡ Optymalizacja zakończona w %.1f sekund (%.1f minut)', ...
    optimization_time, optimization_time/60);

% =========================================================================
% KROK 2.5: SPRAWDZENIE CZY ZNALEZIONO GOLDEN PARAMETERS
% =========================================================================

% Sprawdź czy Random Search znalazł Golden Parameters (95%+)
if strcmp(selected_method, 'random_search') && ...
        isfield(results, 'best_accuracy') && ...
        results.best_accuracy >= 0.95
    
    logSuccess('💎 ZNALEZIONO GOLDEN PARAMETERS! Accuracy: %.1f%%', ...
        results.best_accuracy*100);
    
    % Użyj Golden Parameters do stworzenia finalnej sieci
    logInfo('🚀 Tworzenie finalnej sieci z Golden Parameters...');
    
    golden_params = results.best_params;
    
    % Stwórz finalną sieć z najlepszymi parametrami
    final_net = createNeuralNetwork(...
        'pattern', ...
        golden_params.hidden_layers, ...
        golden_params.train_function, ...
        golden_params.activation_function, ...
        golden_params.learning_rate, ...
        golden_params.epochs, ...
        1e-6);
    
    % Wytrenuj finalną sieć na WSZYSTKICH danych
    logInfo('🎯 Trenowanie finalnej sieci na pełnym zbiorze danych...');
    final_training_start = tic;
    
    final_net = train(final_net, X', Y');
    
    final_training_time = toc(final_training_start);
    
    % Testuj finalną sieć
    final_outputs = final_net(X');
    final_accuracy = sum(vec2ind(final_outputs) == vec2ind(Y')) / size(Y, 1);
    
    logSuccess('🏆 FINALNA SIEĆ - Accuracy: %.1f%% (czas: %.1fs)', ...
        final_accuracy*100, final_training_time);
    
    % Zapisz finalną sieć
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    final_net_filename = sprintf('output/networks/FINAL_GOLDEN_NETWORK_%.1f%%_%s.mat', ...
        final_accuracy*100, timestamp);
    
    save(final_net_filename, 'final_net', 'golden_params', 'final_accuracy');
    logSuccess('💾 Finalna sieć zapisana: %s', final_net_filename);
    
    % Aktualizuj best_model na finalną sieć
    best_model = final_net;
    results.final_accuracy = final_accuracy;
    results.golden_parameters_used = true;
    
else
    logInfo('ℹ️ Nie znaleziono Golden Parameters (95%+). Używam najlepszego wyniku.');
    results.golden_parameters_used = false;
end

% =========================================================================
% KROK 3: PODSUMOWANIE CAŁEGO PROCESU
% =========================================================================

% POPRAWIONE WYWOŁANIE - używaj results.best_params
if isfield(results, 'best_params') && ~isempty(results.best_params)
    final_params = results.best_params;
else
    % Fallback - utwórz strukturę z dostępnych danych
    final_params = struct();
    final_params.accuracy = results.best_accuracy;
    final_params.method = results.method;
    final_params.total_time = results.total_time;
    
    % Domyślne parametry na podstawie najlepszego wyniku
    final_params.learning_rate = 0.08;
    final_params.hidden_layers = [35, 25];
    final_params.train_function = 'trainbr';
    final_params.activation_function = 'logsig';
end

% Teraz użyj final_params zamiast best_params
displayFinalSummary(total_start, loading_time, final_params, ...
    noise_level, num_samples, use_vowels, use_complex, ...
    normalize_features, data_file);

% ===== FINALNE TESTOWANIE Z WIZUALIZACJĄ =====
if strcmp(selected_method, 'random_search') && ...
        isfield(results, 'best_accuracy') && ...
        results.best_accuracy >= 0.95 && ...
        results.golden_parameters_used
    
    logInfo('🎯 ROZPOCZYNAM FINALNE TESTOWANIE Z GOLDEN PARAMETERS...');
    logInfo('💎 Trenowanie finalnej sieci z OKNEM trenowania...');
    
    % Trenowanie finalnej sieci z Golden Parameters
    [final_net, final_results] = trainNeuralNetwork(X, Y, golden_params, true);
    
    % Testowanie finalnej sieci
    final_results = testFinalNetwork(final_net, X, Y, labels, golden_params);
    
    % Wyświetlenie macierzy konfuzji
    logInfo('🎯 Generowanie macierzy konfuzji...');
    plotConfusionMatrix(final_results.true_labels, final_results.predictions, labels, ...
        sprintf('Macierz Konfuzji - skuteczność: %.1f%%', final_results.accuracy*100));
    
    
    logSuccess('📊 Wyświetlono wszystkie wizualizacje dla Golden Parameters!');
    
else
    logInfo('ℹ️ Standardowe testowanie - brak Golden Parameters lub accuracy < 95%%');
end
