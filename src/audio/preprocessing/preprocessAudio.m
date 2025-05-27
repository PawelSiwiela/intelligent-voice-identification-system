function [features, feature_names] = preprocessAudio(file_path, noise_level)
% =========================================================================
% PRZETWARZANIE SYGNAŁU AUDIO I EKSTRAKCJA CECH - UPROSZCZONY
% =========================================================================
% Funkcja wyciąga dokładnie 24 najważniejsze cechy audio
%
% ARGUMENTY:
%   file_path - ścieżka do pliku audio (.wav)
%   noise_level - poziom szumu dodawanego do sygnału (0.0-1.0)
%
% ZWRACA:
%   features - wektor 24 cech liczbowych [1 × 24]
%   feature_names - nazwy 24 cech (cell array)

logDebug('Przetwarzanie: %s', file_path);

try
    % =====================================================================
    % WCZYTANIE I PRZYGOTOWANIE SYGNAŁU
    % =====================================================================
    
    [y, fs] = audioread(file_path);
    
    % Konwersja do mono jeśli stereo
    if size(y, 2) > 1
        y = mean(y, 2);
    end
    
    % Dodanie szumu i filtracja
    noisy_signal = y + noise_level * randn(size(y));
    [filtered_signal, ~] = applyAdaptiveFilters(noisy_signal, y);
    
    % =====================================================================
    % EKSTRAKCJA 24 CECH - WSZYSTKICH NAJWAŻNIEJSZYCH
    % =====================================================================
    
    all_features = struct();
    
    % 1. PODSTAWOWE (5 cech)
    basic = extractBasicFeatures(filtered_signal);
    all_features = mergeStructs(all_features, basic, 'basic');
    
    % 2. OBWIEDNIE (4 cechy)
    envelope = extractEnvelopeFeatures(filtered_signal, 200);
    all_features = mergeStructs(all_features, envelope, 'env');
    
    % 3. FFT (3 cechy)
    fft_feat = extractFFTFeatures(filtered_signal, fs);
    all_features = mergeStructs(all_features, fft_feat, 'freq');
    
    % 4. MFCC (6 cech)
    mfcc = extractMFCCFeatures(filtered_signal, fs);
    all_features = mergeStructs(all_features, mfcc, 'mfcc');
    
    % 5. SPEKTRALNE (3 cechy)
    spectral = extractSpectralFeatures(filtered_signal, fs);
    all_features = mergeStructs(all_features, spectral, 'spec');
    
    % 6. FORMANTY (3 cechy)
    formant = extractFormantFeatures(filtered_signal, fs);
    all_features = mergeStructs(all_features, formant, 'form');
    
    % =====================================================================
    % KONWERSJA NA WEKTOR - PROSTY I BEZPOŚREDNI
    % =====================================================================
    
    feature_names = fieldnames(all_features);
    features = zeros(1, numel(feature_names));
    
    for i = 1:numel(feature_names)
        feature_value = all_features.(feature_names{i});
        
        if length(feature_value) > 1
            features(i) = mean(feature_value);
        else
            features(i) = feature_value;
        end
    end
    
    % Sanityzacja danych
    features(isnan(features)) = 0;
    features(isinf(features)) = 0;
    
    logDebug('✅ Wyekstraktowano %d cech z pliku %s', length(features), file_path);
    
catch ME
    logError('❌ Błąd: %s', ME.message);
    features = zeros(1, 42);
    feature_names = {};
end

end

% =========================================================================
% FUNKCJA POMOCNICZA - ŁĄCZENIE STRUKTUR
% =========================================================================

function merged = mergeStructs(target, source, prefix)
merged = target;
source_fields = fieldnames(source);

for i = 1:length(source_fields)
    new_field_name = sprintf('%s_%s', prefix, source_fields{i});
    merged.(new_field_name) = source.(source_fields{i});
end
end