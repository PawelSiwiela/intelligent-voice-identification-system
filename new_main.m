% Inicjalizacja środowiska
close all; clear all; clc;

% Dodanie ścieżek projektu
addpath(genpath('new_src'));

fprintf('=== TEST WCZYTYWANIA DANYCH AUDIO ===\n\n');

% Parametry wczytywania
noise_level = 0.1;
num_samples = 5;  % Liczba próbek na kategorię
use_vowels = true;
use_complex = true;

% Wywołanie funkcji loadAudioData
try
    tic;
    [X, Y, labels, successful, failed] = loadAudioData(noise_level, num_samples, use_vowels, use_complex);
    elapsed_time = toc;
    
    % Wyświetlenie statystyk
    fprintf('Test zakończony sukcesem!\n');
    fprintf('Czas wykonania: %.2f sekund\n', elapsed_time);
    fprintf('Wczytano %d próbek (nie udało się wczytać: %d)\n', successful, failed);
    fprintf('Wymiary danych: X[%d×%d], Y[%d×%d], %d kategorii\n', ...
        size(X,1), size(X,2), size(Y,1), size(Y,2), length(labels));
catch e
    fprintf('Test nie powiódł się: %s\n', e.message);
end
