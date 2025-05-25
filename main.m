% =========================================================================
% INTELLIGENT VOICE IDENTIFICATION SYSTEM
% =========================================================================
% Główny plik startowy
% =========================================================================

close all;
clear all;
clc;

fprintf('🎵 INTELLIGENT VOICE IDENTIFICATION SYSTEM\n');
fprintf('==========================================\n');

% =========================================================================
% USTAWIENIE ŚCIEŻEK
% =========================================================================

% Dodanie wszystkich podkatalogów src do ścieżki MATLAB
addpath(genpath('src'));
fprintf('📁 Dodano ścieżki do kodu źródłowego\n');

% =========================================================================
% UTWORZENIE KATALOGÓW WYJŚCIOWYCH
% =========================================================================

output_dirs = {'output', 'output\networks', 'output\results', 'output\preprocessed'};
for i = 1:length(output_dirs)
    if ~exist(output_dirs{i}, 'dir')
        mkdir(output_dirs{i});
        fprintf('📂 Utworzono katalog: %s\n', output_dirs{i});
    end
end

% Po utworzeniu katalogów dodaj:
gitkeep_files = {
    'output\networks\.gitkeep',
    'output\results\.gitkeep',
    'output\preprocessed\.gitkeep'
    };

for i = 1:length(gitkeep_files)
    if ~exist(gitkeep_files{i}, 'file')
        fid = fopen(gitkeep_files{i}, 'w');
        fclose(fid);
    end
end

% =========================================================================
% KONFIGURACJA SYSTEMU (PROSTA)
% =========================================================================

% Parametry audio
noise_level = 0.1;
num_samples = 10;
normalize_features = true;

% Kategorie danych
use_vowels = true;
use_complex = true;

fprintf('📋 Konfiguracja systemu:\n');
fprintf('   🔊 Poziom szumu: %.1f\n', noise_level);
fprintf('   📝 Próbek na kategorię: %d\n', num_samples);
fprintf('   🎵 Samogłoski: %s\n', yesno(use_vowels));
fprintf('   💬 Komendy złożone: %s\n', yesno(use_complex));
fprintf('   ⚖️ Normalizacja: %s\n', yesno(normalize_features));

% =========================================================================
% URUCHOMIENIE SYSTEMU
% =========================================================================

try
    fprintf('\n🚀 Uruchamianie systemu...\n');
    
    % Wywołanie głównej funkcji (z folderu src/core/)
    voiceRecognition();
    
    fprintf('\n🎉 System zakończył pracę pomyślnie!\n');
    
catch ME
    fprintf('\n❌ Błąd podczas wykonywania:\n');
    fprintf('   📍 Plik: %s\n', ME.stack(1).file);
    fprintf('   📍 Linia: %d\n', ME.stack(1).line);
    fprintf('   📍 Komunikat: %s\n', ME.message);
end

fprintf('\n👋 Koniec programu\n');