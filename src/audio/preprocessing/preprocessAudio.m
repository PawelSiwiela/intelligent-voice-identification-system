function [features, filtered_signal] = preprocessAudio(file_path, noise_level)
% PREPROCESSAUDIO Przetwarzanie pliku audio i ekstrakcja cech
%
% Składnia:
%   [features, filtered_signal] = preprocessAudio(file_path, noise_level)
%
% Argumenty:
%   file_path - ścieżka do pliku audio
%   noise_level - poziom szumu do dodania (0.0-1.0)
%
% Zwraca:
%   features - wektor cech
%   filtered_signal - przefiltrowany sygnał

try
    % Wczytanie pliku audio
    [y, fs] = audioread(file_path);
    logDebug('Wczytano plik: %s, fs=%dHz, długość=%.2fs', file_path, fs, length(y)/fs);
    
    % Konwersja do mono jeśli stereo
    if size(y, 2) > 1
        y = mean(y, 2);
    end
    
    % Dodanie szumu i filtracja
    noisy_signal = y + noise_level * randn(size(y));
    [filtered_signal, ~] = applyAdaptiveFilters(noisy_signal, y);
    
    % Ekstrakcja cech z przefiltrowanego sygnału
    [features, feature_names] = extractFeatures(filtered_signal, fs);
    
    % Sanityzacja danych
    features(isnan(features)) = 0;
    features(isinf(features)) = 0;
    
    logDebug('✅ Wyekstraktowano %d cech z pliku %s', length(features), file_path);
    
catch e
    logError('❌ Błąd: %s', e.message);
    features = [];
    filtered_signal = [];
end

end