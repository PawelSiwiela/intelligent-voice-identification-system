function saveProcessedData(filename, X, Y, labels, successful_loads, failed_loads, ...
    normalize_flag, normalization_status, noise_level, num_samples, use_vowels, use_complex)
% =========================================================================
% ZAPIS PRZETWORZONYCH DANYCH
% =========================================================================
% Zapisuje wszystkie przetworzone dane wraz z metadanymi
% =========================================================================

% Przygotowanie metadanych
creation_time = datetime('now');
matlab_version = version;

% Zapis do pliku (domyślnie do katalogu output/preprocessed/)
output_path = fullfile('output', 'preprocessed', filename);

save(output_path, 'X', 'Y', 'labels', 'successful_loads', 'failed_loads', ...
    'normalize_flag', 'normalization_status', 'noise_level', 'num_samples', ...
    'use_vowels', 'use_complex', 'creation_time', 'matlab_version');

fprintf('💾 Zapisano dane do: %s\n', output_path);

end