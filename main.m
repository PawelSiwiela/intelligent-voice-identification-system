% =========================================================================
% INTELLIGENT VOICE IDENTIFICATION SYSTEM - GŁÓWNY SKRYPT URUCHAMIAJĄCY
% =========================================================================


clear all;
close all;
clc;

% =========================================================================
% WYŚWIETLENIE NAGŁÓWKA SYSTEMU
% =========================================================================
fprintf('🎵 INTELLIGENT VOICE IDENTIFICATION SYSTEM\n');
fprintf('==========================================\n');

% =========================================================================
% USTAWIENIE ŚCIEŻEK
% =========================================================================

% Dodanie wszystkich podkatalogów src do ścieżki MATLAB
addpath(genpath('src'));
fprintf('📁 Dodano ścieżki do kodu źródłowego\n');

% =========================================================================
% TWORZENIE STRUKTURY KATALOGÓW
% =========================================================================

% Lista katalogów wyjściowych do utworzenia
output_dirs = {
    'output',
    'output\networks',
    'output\results',
    'output\preprocessed',
    'output\logs'
    };

% Lista plików .gitkeep do utworzenia
gitkeep_files = {
    'output\networks\.gitkeep',
    'output\results\.gitkeep',
    'output\preprocessed\.gitkeep',
    'output\logs\.gitkeep'
    };

% Tworzenie katalogów jeśli nie istnieją
for i = 1:length(output_dirs)
    if ~exist(output_dirs{i}, 'dir')
        mkdir(output_dirs{i});
        fprintf('📂 Utworzono katalog: %s\n', output_dirs{i});
    end
end

% Tworzenie plików .gitkeep jeśli nie istnieją
for i = 1:length(gitkeep_files)
    if ~exist(gitkeep_files{i}, 'file')
        fid = fopen(gitkeep_files{i}, 'w');
        if fid ~= -1
            fclose(fid);
            fprintf('📄 Utworzono plik: %s\n', gitkeep_files{i});
        end
    end
end

% =========================================================================
% INICJALIZACJA SYSTEMU LOGOWANIA
% =========================================================================

% Wymuszenie inicjalizacji logowania
logInfo('=== SYSTEM ROZPOZNAWANIA GŁOSU - START ===');
logInfo('Czas rozpoczęcia: %s', datestr(now));

% =========================================================================
% URUCHOMIENIE GŁÓWNEGO SYSTEMU
% =========================================================================

fprintf('🚀 Uruchamianie systemu...\n');
fprintf('\n');

try
    % Wywołanie głównej funkcji systemu rozpoznawania głosu
    voiceRecognition();
    
    % Sukces - system zakończył pracę bez błędów
    logSuccess('🎉 System zakończył pracę pomyślnie!');
    
catch ME
    % Obsługa błędów
    logError('❌ Błąd podczas wykonywania:');
    logError('   📍 Plik: %s', ME.stack(1).file);
    logError('   📍 Linia: %d', ME.stack(1).line);
    logError('   📍 Komunikat: %s', ME.message);
    
    % Wyświetlenie dodatkowych informacji o błędzie
    if length(ME.stack) > 1
        logError('📚 Stos wywołań:');
        for i = 1:min(3, length(ME.stack))
            logError('   %d. %s (linia %d)', i, ME.stack(i).name, ME.stack(i).line);
        end
    end
end

% =========================================================================
% FINALIZACJA
% =========================================================================

logInfo('👋 Koniec programu');

% Zamknięcie pliku log
try
    closeLog();
catch
    % Jeśli zamknięcie loga nie powiedzie się, nie ma problemu
end

fprintf('\n👋 Koniec programu\n');