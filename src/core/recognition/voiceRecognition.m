function voiceRecognition()
% =========================================================================
% SYSTEM ROZPOZNAWANIA GŁOSU - GŁÓWNY SKRYPT
% =========================================================================

close all;
clear all;
clc;

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
logInfo(''); % Pusta linia

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
% KONFIGURACJA OPTYMALIZACJI SIECI - WYBÓR METODY
% =========================================================================

% DOSTĘPNE METODY OPTYMALIZACJI:
optimization_methods = {
    'grid_search',    % Systematyczne przeszukiwanie wszystkich kombinacji
    'random_search',  % Losowe próbkowanie z przestrzeni parametrów
    'bayesian',       % Inteligentne przeszukiwanie Bayesowskie
    'genetic',        % Algorytm ewolucyjny
    'adam'           % ✨ NOWY: Optymalizacja z Deep Learning Toolbox ADAM
    };

% WYBÓR METODY (zmień tutaj):
selected_method = 'random_search';  % ✨ Użyj ADAM!

% Walidacja wyboru
if ~ismember(selected_method, optimization_methods)
    logError('Nieznana metoda: %s. Dostępne: %s', selected_method, strjoin(optimization_methods, ', '));
    selected_method = 'grid_search'; % Fallback
end

logInfo('🔍 Wybrana metoda optymalizacji: %s', upper(selected_method));

optimization_start = tic;
switch selected_method
    case 'grid_search'
        logInfo('🔍 Uruchamianie przeszukiwania siatki...');
        [results, best_model] = gridSearchOptimizer(X, Y, labels);
        
    case 'random_search'
        logInfo('🎲 Uruchamianie losowego przeszukiwania...');
        [results, best_model] = randomSearchOptimizer(X, Y, labels);
        
    case 'bayesian'
        logInfo('📈 Uruchamianie optymalizacji bayesowskiej...');
        [results, best_model] = bayesianOptimizer(X, Y, labels);
        
    case 'genetic'
        logInfo('🧬 Uruchamianie algorytmu genetycznego...');
        [results, best_model] = geneticOptimizer(X, Y, labels);
        
    case 'adam'
        logInfo('🚀 Uruchamianie optymalizacji ADAM...');
        config = adamConfig();
        displayAdamConfig(config, X, Y, labels);
        [results, best_model] = adamOptimizer(X, Y, labels, config);
        
    otherwise
        logError('Nieznana metoda: %s', selected_method);
        return;
end
optimization_time = toc(optimization_start);

logSuccess('⚡ Optymalizacja %s zakończona w %.1f s (%.1f min)', ...
    upper(selected_method), optimization_time, optimization_time/60);

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
