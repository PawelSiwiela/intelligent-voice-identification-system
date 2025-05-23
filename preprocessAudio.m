function [features, feature_names] = preprocessAudio(file_path, noise_level)
% Wczytanie sygnału
[y, fs] = audioread(file_path);

% Dodanie szumu i filtracja adaptacyjna
noisy_signal = y + noise_level * randn(size(y));
[filtered_signal, ~] = applyAdaptiveFilters(noisy_signal, y);

% Obliczenie obwiedni
[upper_env, lower_env] = envelope(filtered_signal, 200, 'peak');

% FFT
Y = fft(filtered_signal);
N = length(Y);
frequency = (0:N-1)*(fs/N);

% Predefiniowane przedziały częstotliwości
frequency_ranges = [100, 150; 220, 300; 350, 420];
num_ranges = size(frequency_ranges, 1);
fft_features = zeros(1, num_ranges);

% Analiza częstotliwości w przedziałach
for r = 1:num_ranges
    range_start = frequency_ranges(r, 1);
    range_end = frequency_ranges(r, 2);
    idx_range = (frequency >= range_start) & (frequency <= range_end);
    fft_features(r) = max(abs(Y(idx_range)));
end

% Obliczenie cech statystycznych
features_struct = struct();

% Cechy podstawowe
features_struct.min = min(filtered_signal);
features_struct.max = max(filtered_signal);
features_struct.mean = mean(filtered_signal);
features_struct.std = std(filtered_signal);
features_struct.kurtosis = kurtosis(filtered_signal);
features_struct.skewness = skewness(filtered_signal);

% Cechy obwiedni górnej
features_struct.upper_min = min(upper_env);
features_struct.upper_max = max(upper_env);
features_struct.upper_mean = mean(upper_env);
features_struct.upper_std = std(upper_env);

% Cechy obwiedni dolnej
features_struct.lower_min = min(lower_env);
features_struct.lower_max = max(lower_env);
features_struct.lower_mean = mean(lower_env);
features_struct.lower_std = std(lower_env);

% Cechy FFT
for r = 1:num_ranges
    features_struct.(['fft_range_', num2str(r)]) = fft_features(r);
end

% Konwersja struktury na wektor
feature_names = fieldnames(features_struct);
features = zeros(1, numel(feature_names));

for i = 1:numel(feature_names)
    % Pobierz wartość cechy bez normalizacji
    features(i) = features_struct.(feature_names{i});
end

end