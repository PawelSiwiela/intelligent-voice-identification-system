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
[X, Y, labels, successful_loads, failed_loads] = loadAudioData(noise_level, num_samples, use_vowels, use_complex);
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
    'TestRatio', 0.2, ...
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