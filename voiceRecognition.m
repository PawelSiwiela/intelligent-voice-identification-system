close all;
clear all;
clc;

% Parametry wczytywania danych
noise_level = 0.1;
num_samples = 10;
use_vowels = false;
use_complex = true;

fprintf('Rozpoczęcie systemu rozpoznawania głosu...\n');
total_start = tic;

% KROK 1: Wczytanie danych audio
fprintf('\n=== KROK 1: Wczytywanie danych audio ===\n');
loading_start = tic;

% Sprawdzenie czy istnieją już przetworzone dane
data_file = 'loaded_audio_data.mat';
if  exist(data_file, 'file')
    fprintf('Znaleziono plik z danymi: %s\n', data_file);
    fprintf('Wczytywanie zapisanych danych...\n');
    
    loaded_data = load(data_file);
    X = loaded_data.X;
    Y = loaded_data.Y;
    labels = loaded_data.labels;
    successful_loads = loaded_data.successful_loads;
    failed_loads = loaded_data.failed_loads;
    
    fprintf('Dane zostały wczytane z pliku!\n');
    fprintf('Rozmiar macierzy X: %dx%d\n', size(X,1), size(X,2));
    fprintf('Rozmiar macierzy Y: %dx%d\n', size(Y,1), size(Y,2));
    fprintf('Liczba kategorii: %d\n', length(labels));
else
    fprintf('Nie znaleziono pliku z danymi. Przetwarzanie od nowa...\n');
    fprintf('Przetwarzanie danych od nowa (use_existing_data = false)...\n');
    
    [X, Y, labels, successful_loads, failed_loads] = loadAudioData(noise_level, num_samples, use_vowels, use_complex);
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
    'TestSamplesPerCategory', 2, ...  % 2 próbki na kategorię do testu
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
if  exist(data_file, 'file')
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