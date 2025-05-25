function [features, feature_names] = preprocessAudio(file_path, noise_level)
% =========================================================================
% PRZETWARZANIE SYGNAŁU AUDIO I EKSTRAKCJA CECH
% =========================================================================
% Funkcja do wczytywania, filtrowania i ekstrakcji cech z sygnałów audio
%
% ARGUMENTY:
%   file_path - ścieżka do pliku audio (.wav)
%   noise_level - poziom szumu dodawanego do sygnału (0.0-1.0)
%
% ZWRACA:
%   features - wektor cech liczbowych [1 × liczba_cech]
%   feature_names - nazwy cech (cell array)
%
% EKSTRAKTOWANE CECHY:
%   • Cechy podstawowe sygnału (min, max, średnia, odchylenie, skośność, kurtoza)
%   • Cechy obwiedni górnej i dolnej (min, max, średnia, odchylenie)
%   • Cechy częstotliwościowe FFT w predefiniowanych zakresach
% =========================================================================

% =========================================================================
% WCZYTYWANIE I PRZYGOTOWANIE SYGNAŁU
% =========================================================================

logDebug('Rozpoczęcie przetwarzania pliku: %s', file_path);

try
    % Wczytanie sygnału audio
    [y, fs] = audioread(file_path);
    logDebug('Wczytano sygnał: długość=%d próbek, fs=%d Hz', length(y), fs);
    
    % Sprawdzenie długości sygnału
    if length(y) < 100
        logWarning('Plik %s ma tylko %d próbek - może być uszkodzony', file_path, length(y));
    end
    
    % Dodanie szumu gaussowskiego i filtracja adaptacyjna
    noisy_signal = y + noise_level * randn(size(y));
    [filtered_signal, ~] = applyAdaptiveFilters(noisy_signal, y);
    
    % =========================================================================
    % ANALIZA OBWIEDNI SYGNAŁU
    % =========================================================================
    
    % Obliczenie obwiedni górnej i dolnej sygnału
    [upper_env, lower_env] = envelope(filtered_signal, 200, 'peak');
    
    % =========================================================================
    % ANALIZA CZĘSTOTLIWOŚCIOWA (FFT)
    % =========================================================================
    
    % Obliczenie transformaty Fouriera
    Y = fft(filtered_signal);
    N = length(Y);
    frequency = (0:N-1)*(fs/N);
    
    % Predefiniowane zakresy częstotliwości dla analizy głosu
    frequency_ranges = [
        100, 150;    % Zakres niskich częstotliwości
        220, 300;    % Zakres średnich częstotliwości
        350, 420     % Zakres wysokich częstotliwości
        ];
    
    num_ranges = size(frequency_ranges, 1);
    fft_features = zeros(1, num_ranges);
    
    % Ekstrakcja cech z każdego zakresu częstotliwości
    for r = 1:num_ranges
        range_start = frequency_ranges(r, 1);
        range_end = frequency_ranges(r, 2);
        
        % Znalezienie indeksów dla danego zakresu częstotliwości
        idx_range = (frequency >= range_start) & (frequency <= range_end);
        
        % Wyznaczenie maksymalnej amplitudy w zakresie
        if any(idx_range)
            fft_features(r) = max(abs(Y(idx_range)));
        else
            fft_features(r) = 0;
        end
    end
    
    % =========================================================================
    % EKSTRAKCJA CECH STATYSTYCZNYCH
    % =========================================================================
    
    % Struktura do przechowywania wszystkich cech
    features_struct = struct();
    
    % Cechy podstawowe przefiltrowanego sygnału
    features_struct.min = min(filtered_signal);           % Wartość minimalna
    features_struct.max = max(filtered_signal);           % Wartość maksymalna
    features_struct.mean = mean(filtered_signal);         % Wartość średnia
    features_struct.std = std(filtered_signal);           % Odchylenie standardowe
    features_struct.kurtosis = kurtosis(filtered_signal); % Kurtoza (spłaszczenie rozkładu)
    features_struct.skewness = skewness(filtered_signal); % Skośność rozkładu
    
    % Cechy obwiedni górnej
    features_struct.upper_min = min(upper_env);     % Min obwiedni górnej
    features_struct.upper_max = max(upper_env);     % Max obwiedni górnej
    features_struct.upper_mean = mean(upper_env);   % Średnia obwiedni górnej
    features_struct.upper_std = std(upper_env);     % Odchylenie std obwiedni górnej
    
    % Cechy obwiedni dolnej
    features_struct.lower_min = min(lower_env);     % Min obwiedni dolnej
    features_struct.lower_max = max(lower_env);     % Max obwiedni dolnej
    features_struct.lower_mean = mean(lower_env);   % Średnia obwiedni dolnej
    features_struct.lower_std = std(lower_env);     % Odchylenie std obwiedni dolnej
    
    % Cechy częstotliwościowe FFT
    for r = 1:num_ranges
        field_name = sprintf('fft_range_%d', r);
        features_struct.(field_name) = fft_features(r);
    end
    
    % =========================================================================
    % KONWERSJA I WALIDACJA WYNIKÓW
    % =========================================================================
    
    % Konwersja struktury na wektor liczbowy
    feature_names = fieldnames(features_struct);
    features = zeros(1, numel(feature_names));
    
    for i = 1:numel(feature_names)
        features(i) = features_struct.(feature_names{i});
    end
    
    % Usunięcie wartości NaN i nieskończonych (zabezpieczenie)
    features(isnan(features)) = 0;      % NaN → 0
    features(isinf(features)) = 0;      % ±Inf → 0
    
    % Sprawdzenie poprawności wyników
    if any(~isfinite(features))
        warning('Wykryto nieprawidłowe wartości w cechach dla pliku: %s', file_path);
    end
    
    logDebug('Wyekstraktowano %d cech z pliku %s', length(features), file_path);
    
catch ME
    logError('Błąd przetwarzania pliku %s: %s', file_path, ME.message);
    features = zeros(1, 18);
    feature_names = {};
    return;
end

end
