function [features, feature_names] = extractFeatures(signal, fs)
% EXTRACTFEATURES Ekstrahuje wszystkie cechy z sygnału audio
%
% Składnia:
%   [features, feature_names] = extractFeatures(signal, fs)
%
% Argumenty:
%   signal - sygnał audio
%   fs - częstotliwość próbkowania
%
% Zwraca:
%   features - wektor cech
%   feature_names - nazwy wyekstrahowanych cech

% Przygotowanie struktury na cechy
all_features = struct();

% Ekstrakcja wszystkich dostępnych typów cech
basic = basicFeatures(signal);
all_features = mergeStructs(all_features, basic, 'basic');

envelope = envelopeFeatures(signal);
all_features = mergeStructs(all_features, envelope, 'env');

spectral = spectralFeatures(signal, fs);
all_features = mergeStructs(all_features, spectral, 'spec');

fft_feat = fftFeatures(signal, fs);
all_features = mergeStructs(all_features, fft_feat, 'fft');

formant = formantFeatures(signal, fs);
all_features = mergeStructs(all_features, formant, 'form');

mfcc = mfccFeatures(signal, fs);
all_features = mergeStructs(all_features, mfcc, 'mfcc');

% Konwersja struktury na wektor numeryczny i nazwy cech
field_names = fieldnames(all_features);
features = zeros(1, length(field_names));

for i = 1:length(field_names)
    features(i) = all_features.(field_names{i});
    feature_names{i} = field_names{i};
end

% Sanityzacja danych
features(isnan(features)) = 0;
features(isinf(features)) = 0;

% Informacja o liczbie wyekstrahowanych cech
logDebug('✅ Wyekstraktowano %d cech', length(features));
end