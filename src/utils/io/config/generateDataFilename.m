function [filename, status] = generateDataFilename(config_string, normalize_flag)
% =========================================================================
% GENEROWANIE NAZWY PLIKU DANYCH
% =========================================================================
% Tworzy nazwę pliku na podstawie konfiguracji i flagi normalizacji
% =========================================================================

if normalize_flag
    filename = sprintf('loaded_audio_data_%s_normalized.mat', config_string);
    status = 'znormalizowane';
else
    filename = sprintf('loaded_audio_data_%s_raw.mat', config_string);
    status = 'nieznormalizowane';
end

end