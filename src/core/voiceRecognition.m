% =========================================================================
% SYSTEM ROZPOZNAWANIA GŁOSU - GŁÓWNY SKRYPT
% =========================================================================
% Autor: [Twoje imię]
% Data: [Data utworzenia]
% Opis: Główny skrypt systemu rozpoznawania głosu wykorzystujący sieci
%       neuronowe do klasyfikacji próbek audio (samogłoski i komendy złożone)
% =========================================================================

close all;
clear all;
clc;

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

fprintf('🎵 SYSTEM ROZPOZNAWANIA GŁOSU - ROZPOCZĘCIE\n');
fprintf('==========================================\n');
total_start = tic;

% =========================================================================
% KROK 1: WCZYTYWANIE I PRZETWARZANIE DANYCH AUDIO
% =========================================================================
fprintf('\n=== KROK 1: Wczytywanie danych audio ===\n');
loading_start = tic;

% Wyświetlenie aktualnej konfiguracji
fprintf('📋 Konfiguracja systemu:\n');
fprintf('   • Samogłoski: %s\n', yesno(use_vowels));
fprintf('   • Komendy złożone: %s\n', yesno(use_complex));
fprintf('   • Próbek na kategorię: %d\n', num_samples);
fprintf('   • Poziom szumu: %.1f\n', noise_level);
fprintf('   • Normalizacja cech: %s\n', yesno(normalize_features));

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
    fprintf('\n✅ Znaleziono plik z danymi: %s\n', data_file);
    load_existing = true;
else
    fprintf('\n⚠️ Nie znaleziono pliku z danymi: %s\n', data_file);
    fprintf('📦 Rozpoczynam przetwarzanie danych od nowa...\n');
    load_existing = false;
end

% Wczytanie istniejących danych i sprawdzenie kompatybilności
if load_existing
    fprintf('📂 Wczytywanie zapisanych danych z %s...\n', data_file);
    
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
    fprintf('\n🔄 Przetwarzanie danych od nowa...\n');
    
    try
        [X, Y, labels, successful_loads, failed_loads] = loadAudioData(...
            noise_level, num_samples, use_vowels, use_complex, normalize_features);
        
        % Sprawdzenie czy dane zostały wczytane pomyślnie
        if isempty(X)
            fprintf('❌ Nie udało się wczytać danych lub proces został zatrzymany.\n');
            return;
        end
        
        fprintf('✅ Przetwarzanie zakończone pomyślnie!\n');
        
    catch ME
        if contains(ME.message, 'zatrzymane')
            fprintf('🛑 Proces został zatrzymany przez użytkownika.\n');
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
% KROK 2: TRENOWANIE SIECI NEURONOWEJ
% =========================================================================
fprintf('\n=== KROK 2: Trenowanie sieci neuronowej ===\n');

[net, results] = trainNeuralNetwork(X, Y, labels, ...
    'HiddenLayers', [15 8], ...    % Architektura sieci: 15 neuronów w 1. warstwie, 8 w 2.
    'Epochs', 1500, ...            % Maksymalna liczba epok trenowania
    'Goal', 1e-7, ...              % Docelowy błąd trenowania
    'TestSamplesPerCategory', 2, ... % Liczba próbek testowych na kategorię
    'SaveResults', true, ...        % Czy zapisać wyniki do pliku
    'ShowPlots', true);             % Czy wyświetlić wykresy

% =========================================================================
% KROK 3: PODSUMOWANIE CAŁEGO PROCESU
% =========================================================================
displayFinalSummary(total_start, loading_time, results, ...
    noise_level, num_samples, use_vowels, use_complex, ...
    normalize_features, data_file);
