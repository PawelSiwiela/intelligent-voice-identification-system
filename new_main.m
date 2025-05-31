% INTELLIGENT VOICE IDENTIFICATION SYSTEM
% =========================================================================
% Główny skrypt demonstracyjny
% =========================================================================

% Inicjalizacja środowiska
close all; clear all; clc;

% Dodanie ścieżek projektu
addpath(genpath('new_src'));

fprintf('=== SYSTEM ROZPOZNAWANIA MOWY ===\n\n');

% ==== KONFIGURACJA SYSTEMU ====
config = struct();

% Parametry danych
config.noise_level = 0.1;        % Poziom szumu
config.num_samples = 10;          % Liczba próbek na kategorię
config.normalize_features = true; % Czy normalizować cechy

% Wybór trybu (scenariusza) - odkomentuj jeden z poniższych:
config.scenario = 'all';         % wszystkie dane (samogłoski + komendy)
%config.scenario = 'vowels';      % tylko samogłoski
%config.scenario = 'commands';    % tylko komendy

% Parametry optymalizacji
config.max_trials = 20;          % Liczba prób w random search
config.golden_accuracy = 0.95;   % Próg "złotej dokładności"
config.early_stopping = true;    % Czy przerwać po znalezieniu dobrego wyniku
config.show_visualizations = true; % Czy pokazywać wizualizacje

% ==== URUCHOMIENIE SYSTEMU ====
try
    fprintf('Rozpoczynam identyfikację głosu...\n');
    
    % Uruchomienie głównej funkcji
    tic;
    [best_net, best_tr, results] = voiceRecognition(config);
    elapsed_time = toc;
    
    % Wyświetlenie podsumowania
    fprintf('\n=== PODSUMOWANIE DZIAŁANIA SYSTEMU ===\n');
    fprintf('Czas wykonania: %.2f sekund\n', elapsed_time);
    fprintf('Najlepszy typ sieci: %s\n', results.best_network_type);
    fprintf('Najlepsza dokładność: %.2f%%\n', results.best_accuracy * 100);
    
catch e
    % Obsługa błędów
    fprintf('\n❌ BŁĄD: %s\n', e.message);
    if ~isempty(e.stack)
        fprintf('Ścieżka: %s\n', e.stack(1).name);
        fprintf('Linia: %d\n', e.stack(1).line);
    end
end

fprintf('\n=== KONIEC DZIAŁANIA SYSTEMU ===\n');
