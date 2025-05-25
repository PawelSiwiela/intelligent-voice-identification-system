close all;
clear all;
clc;

% Parametry wczytywania danych
noise_level = 0.1;
num_samples = 10;
use_vowels = true;
use_complex = true;

% NOWY PARAMETR: normalizacja cech
normalize_features = true;  % Zmień na false jeśli nie chcesz normalizować

fprintf('Rozpoczęcie systemu rozpoznawania głosu...\n');
total_start = tic;

% KROK 1: Wczytanie danych audio
fprintf('\n=== KROK 1: Wczytywanie danych audio ===\n');
loading_start = tic;

% Informacja o konfiguracji przed rozpoczęciem
fprintf('Konfiguracja wczytywania:\n');
fprintf('- Samogłoski: %s\n', yesno(use_vowels));
fprintf('- Komendy złożone: %s\n', yesno(use_complex));
fprintf('- Próbek na kategorię: %d\n', num_samples);
fprintf('- Poziom szumu: %.1f\n', noise_level);
fprintf('- Normalizacja cech: %s\n', yesno(normalize_features));

% Tworzenie nazwy pliku na podstawie konfiguracji
config_string = '';
if use_vowels && use_complex
    config_string = 'vowels_complex';
elseif use_vowels
    config_string = 'vowels_only';
elseif use_complex
    config_string = 'complex_only';
else
    config_string = 'empty';
end

% Sprawdzenie czy istnieją już przetworzone dane
if normalize_features
    data_file = sprintf('loaded_audio_data_%s_normalized.mat', config_string);
else
    data_file = sprintf('loaded_audio_data_%s_raw.mat', config_string);
end

data_exists = exist(data_file, 'file');

if data_exists
    fprintf('\n✓ Znaleziono plik z danymi: %s\n', data_file);
    load_existing = true;
else
    fprintf('\n⚠ Nie znaleziono pliku z danymi: %s\n', data_file);
    fprintf('Przetwarzanie danych od nowa...\n');
    load_existing = false;
end

if load_existing
    fprintf('Wczytywanie zapisanych danych z %s...\n', data_file);
    
    loaded_data = load(data_file);
    
    % SPRAWDZENIE KOMPATYBILNOŚCI
    config_compatible = true;
    if isfield(loaded_data, 'use_vowels') && isfield(loaded_data, 'use_complex')
        if loaded_data.use_vowels ~= use_vowels || loaded_data.use_complex ~= use_complex
            fprintf('⚠ Wykryto niezgodność konfiguracji:\n');
            fprintf('  Plik: samogłoski=%s, pary słów=%s\n', yesno(loaded_data.use_vowels), yesno(loaded_data.use_complex));
            fprintf('  Aktualna: samogłoski=%s, pary słów=%s\n', yesno(use_vowels), yesno(use_complex));
            fprintf('  Przetwarzanie danych od nowa...\n');
            fprintf('  Uwaga: zmiana konfiguracji może wpłynąć na jakość rozpoznawania.\n');
            config_compatible = false;
        end
    else
        fprintf('⚠ Brak informacji o konfiguracji w pliku. Przetwarzanie od nowa...\n');
        config_compatible = false;
    end
    
    if config_compatible
        X = loaded_data.X;
        Y = loaded_data.Y;
        labels = loaded_data.labels;
        successful_loads = loaded_data.successful_loads;
        failed_loads = loaded_data.failed_loads;
        
        fprintf('✅ Dane zostały wczytane z pliku!\n');
        fprintf('Rozmiar macierzy X: %dx%d\n', size(X,1), size(X,2));
        fprintf('Rozmiar macierzy Y: %dx%d\n', size(Y,1), size(Y,2));
        fprintf('Liczba kategorii: %d\n', length(labels));
        if isfield(loaded_data, 'normalization_status')
            fprintf('Status normalizacji: %s\n', loaded_data.normalization_status);
        end
    else
        load_existing = false;  % Wymuś przetwarzanie od nowa
    end
end

% Jeśli load_existing=false (z powodu niezgodności lub braku pliku)
if ~load_existing
    fprintf('\n⚠ Przetwarzanie danych od nowa...\n');
    
    try
        [X, Y, labels, successful_loads, failed_loads] = loadAudioData(noise_level, num_samples, use_vowels, use_complex, normalize_features);
        
        % Sprawdź czy dane zostały wczytane pomyślnie
        if isempty(X)
            fprintf('❌ Nie udało się wczytać danych lub proces został zatrzymany.\n');
            return;
        end
        
        fprintf('✓ Przetwarzanie zakończone!\n');
        
    catch ME
        if contains(ME.message, 'zatrzymane')
            fprintf('🛑 Proces został zatrzymany przez użytkownika.\n');
            return;
        else
            rethrow(ME);
        end
    end
end

loading_time = toc(loading_start);
fprintf('Czas wczytywania danych: %.2f sekund (%.2f minut)\n', loading_time, loading_time/60);
fprintf('Udane wczytania: %d\n', successful_loads);
fprintf('Nieudane wczytania: %d\n', failed_loads);

% KROK 2: Trenowanie sieci neuronowej
fprintf('\n=== KROK 2: Trenowanie sieci neuronowej ===\n');
[net, results] = trainNeuralNetwork(X, Y, labels, ...
    'HiddenLayers', [15 8], ...
    'Epochs', 1500, ...
    'Goal', 1e-7, ...
    'TestSamplesPerCategory', 2, ...
    'SaveResults', true, ...
    'ShowPlots', true);

% KROK 3: Podsumowanie całego procesu
total_time = toc(total_start);
fprintf('\n=== PODSUMOWANIE ===\n');
fprintf('Całkowity czas wykonania: %.2f sekund (%.2f minut)\n', total_time, total_time/60);
fprintf('  - Wczytywanie danych: %.2f sekund (%.1f%%)\n', loading_time, 100*loading_time/total_time);
if isfield(results, 'training_time')
    fprintf('  - Trenowanie sieci: %.2f sekund (%.1f%%)\n', results.training_time, 100*results.training_time/total_time);
end
if isfield(results, 'testing_time')
    fprintf('  - Testowanie sieci: %.2f sekund (%.1f%%)\n', results.testing_time, 100*results.testing_time/total_time);
end

if isfield(results, 'accuracy')
    fprintf('\nOsiągnięta dokładność: %.2f%%\n', results.accuracy * 100);
end

fprintf('\nSystem rozpoznawania głosu został pomyślnie uruchomiony!\n');

% Dodatkowe informacje o używanych danych
fprintf('\n=== INFORMACJE O DANYCH ===\n');
fprintf('Poziom szumu: %.1f\n', noise_level);
fprintf('Próbek na kategorię: %d\n', num_samples);
fprintf('Używa samogłoski: %s\n', yesno(use_vowels));
fprintf('Używa komendy złożone: %s\n', yesno(use_complex));
fprintf('Normalizacja cech: %s\n', yesno(normalize_features));
if exist(data_file, 'file')
    fprintf('Źródło danych: plik %s\n', data_file);
else
    fprintf('Źródło danych: przetwarzanie na żywo\n');
end

function str = yesno(logical_val)
if logical_val
    str = 'TAK';
else
    str = 'NIE';
end
end