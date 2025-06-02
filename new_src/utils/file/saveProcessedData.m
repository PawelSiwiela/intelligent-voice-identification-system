function saveProcessedData(X, Y, labels, successful_loads, failed_loads, config)
% SAVEPROCESSEDDATA Zapisuje przetworzone dane audio do pliku
%
% Argumenty:
%   X - macierz cech
%   Y - macierz etykiet
%   labels - nazwy kategorii
%   successful_loads, failed_loads - statystyki wczytywania
%   config - struktura z konfiguracją przetwarzania

% Generowanie nazwy pliku
if config.normalize
    filename = sprintf('loaded_audio_data_n%d_s%d_%s_%s_normalized.mat', ...
        round(config.noise_level*100), config.num_samples, ...
        selectFlag(config.use_vowels, 'vowels'), selectFlag(config.use_complex, 'complex'));
    normalization_status = 'znormalizowane';
else
    filename = sprintf('loaded_audio_data_n%d_s%d_%s_%s_raw.mat', ...
        round(config.noise_level*100), config.num_samples, ...
        selectFlag(config.use_vowels, 'vowels'), selectFlag(config.use_complex, 'complex'));
    normalization_status = 'surowe';
end

% Sprawdź istnienie folderu wyjściowego
output_dir = fullfile('output', 'preprocessed');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

% Pełna ścieżka do pliku
output_path = fullfile(output_dir, filename);

% Zapisz dane
logInfo('💾 Zapisywanie przetworzonych danych do pliku...');
save(output_path, 'X', 'Y', 'labels', 'successful_loads', 'failed_loads', ...
    'config');

logSuccess('✅ Dane zostały zapisane do pliku %s (cechy: %s)', output_path, normalization_status);
end

function flag_text = selectFlag(flag, text)
if flag
    flag_text = text;
else
    flag_text = ['no_' text];
end
end