function [data, exists] = loadCachedData(config)
% LOADCACHEDDATA Sprawdza czy istnieją zapisane dane i wczytuje je
%
% Argumenty:
%   config - struktura z konfiguracją przetwarzania
%
% Zwraca:
%   data - struktura z wczytanymi danymi lub pusta
%   exists - flaga czy dane istniały i zostały wczytane

% Inicjalizacja
data = struct();
exists = false;

% Generowanie nazwy pliku
if config.normalize
    filename = sprintf('loaded_audio_data_n%d_s%d_%s_%s_normalized.mat', ...
        round(config.noise_level*100), config.num_samples, ...
        selectFlag(config.use_vowels, 'vowels'), selectFlag(config.use_complex, 'complex'));
else
    filename = sprintf('loaded_audio_data_n%d_s%d_%s_%s_raw.mat', ...
        round(config.noise_level*100), config.num_samples, ...
        selectFlag(config.use_vowels, 'vowels'), selectFlag(config.use_complex, 'complex'));
end

% Pełna ścieżka do pliku
data_file = fullfile('output', 'preprocessed', filename);

% Sprawdzenie czy istnieje plik
if exist(data_file, 'file')
    logSuccess('💾 Znaleziono zapisane dane: %s', data_file);
    
    try
        % Wczytanie danych
        loaded_data = load(data_file);
        
        % Sprawdzenie zgodności konfiguracji
        saved_config = loaded_data.config;
        config_ok = isConfigMatching(config, saved_config);
        
        if config_ok
            % Dane są zgodne, można je użyć
            data = loaded_data;
            exists = true;
            
            logInfo('📊 Wczytano dane: %d próbek, %d cech, %d kategorii', ...
                size(loaded_data.X, 1), size(loaded_data.X, 2), size(loaded_data.Y, 2));
        else
            logInfo('🔄 Konfiguracja się zmieniła, wczytam dane od nowa');
        end
    catch e
        logWarning('⚠️ Problem z wczytaniem danych: %s', e.message);
        logInfo('🔄 Przetwarzam dane od nowa');
    end
end

end

function flag_text = selectFlag(flag, text)
if flag
    flag_text = text;
else
    flag_text = ['no_' text];
end
end

function match = isConfigMatching(config1, config2)
% Porównuje dwie konfiguracje czy są zgodne

% Sprawdź główne pola konfiguracji
match = true;
if config1.noise_level ~= config2.noise_level
    logWarning('⚠️ Różnica w poziomie szumu: zapisane=%.2f, żądane=%.2f', ...
        config2.noise_level, config1.noise_level);
    match = false;
end

if config1.num_samples ~= config2.num_samples
    logWarning('⚠️ Różnica w liczbie próbek: zapisane=%d, żądane=%d', ...
        config2.num_samples, config1.num_samples);
    match = false;
end

if config1.use_vowels ~= config2.use_vowels || config1.use_complex ~= config2.use_complex
    logWarning('⚠️ Różnica w konfiguracji kategorii danych');
    match = false;
end

if config1.normalize ~= config2.normalize
    logWarning('⚠️ Różnica w normalizacji cech: zapisane=%d, żądane=%d', ...
        config2.normalize, config1.normalize);
    match = false;
end
end