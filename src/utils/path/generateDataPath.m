function [file_path, file_name] = generateDataPath(config)
% GENERATEDATAPATH Generuje ścieżkę i nazwę pliku dla przetworzonych danych audio
%
% Składnia:
%   [file_path, file_name] = generateDataPath(config)
%
% Argumenty:
%   config - struktura z konfiguracją przetwarzania zawierająca pola:
%     - noise_level: poziom szumu (0.0-1.0)
%     - num_samples: liczba próbek na kategorię
%     - use_vowels: czy używać samogłosek (true/false)
%     - use_complex: czy używać komend złożonych (true/false)
%     - normalize: czy dane są znormalizowane (true/false)
%
% Zwraca:
%   file_path - pełna ścieżka do pliku danych
%   file_name - nazwa pliku danych (bez ścieżki)

% Generowanie odpowiednich flag tekstowych dla konfiguracji
vowels_flag = selectFlag(config.use_vowels, 'vowels');
complex_flag = selectFlag(config.use_complex, 'complex');

% Tworzenie nazwy pliku zawierającej informacje o konfiguracji
% Format: loaded_audio_data_n[noise]_s[samples]_[vowels]_[complex]_[normalization].mat
if config.normalize
    file_name = sprintf('loaded_audio_data_n%d_s%d_%s_%s_normalized.mat', ...
        round(config.noise_level*100), config.num_samples, ...
        vowels_flag, complex_flag);
else
    file_name = sprintf('loaded_audio_data_n%d_s%d_%s_%s_raw.mat', ...
        round(config.noise_level*100), config.num_samples, ...
        vowels_flag, complex_flag);
end

% Katalog dla przetworzonych danych
output_dir = fullfile('output', 'preprocessed');

% Sprawdzenie istnienia katalogu i ewentualne utworzenie
if ~exist(output_dir, 'dir')
    [success, msg] = mkdir(output_dir);
    if ~success
        logWarning('⚠️ Nie można utworzyć katalogu dla przetworzonych danych: %s', msg);
    else
        logInfo('📁 Utworzono katalog dla przetworzonych danych: %s', output_dir);
    end
end

% Zwrócenie pełnej ścieżki
file_path = fullfile(output_dir, file_name);

end

function flag_text = selectFlag(flag, text)
% SELECTFLAG Generuje tekst flagi na podstawie wartości logicznej
if flag
    flag_text = text;
else
    flag_text = ['no_' text];
end
end