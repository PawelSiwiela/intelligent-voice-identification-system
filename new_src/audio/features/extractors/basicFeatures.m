function features = basicFeatures(signal)
% BASICFEATURES Ekstrakcja podstawowych cech sygnału audio
%
% Składnia:
%   features = basicFeatures(signal)
%
% Argumenty:
%   signal - sygnał audio
%
% Zwraca:
%   features - struktura zawierająca podstawowe cechy sygnału
%     - mean: Średnia
%     - std: Odchylenie standardowe
%     - rms: Wartość skuteczna
%     - range: Zakres wartości
%     - zero_crossing_rate: Częstość przejść przez zero
%     - variance: Wariancja
%     - skewness: Skośność
%     - kurtosis: Kurtoza

% Inicjalizacja struktury wynikowej
features = struct();

% 1. Średnia (mean) - wartość oczekiwana amplitudy sygnału
features.mean = mean(signal);

% 2. Odchylenie standardowe (std) - miara rozrzutu amplitudy wokół średniej
features.std = std(signal);

% 3. Wartość skuteczna (RMS) - miara "głośności" sygnału
features.rms = sqrt(mean(signal.^2));

% 4. Zakres wartości (range) - różnica między maksymalną a minimalną wartością
features.range = max(signal) - min(signal);

% 5. Częstość przejść przez zero (Zero-Crossing Rate)
zero_crossings = sum(abs(diff(sign(signal)) / 2));
features.zero_crossing_rate = zero_crossings / (length(signal) - 1);

% 6. Wariancja (variance) - kwadrat odchylenia standardowego
features.variance = var(signal);

% 7. Skośność (skewness) - miara asymetrii rozkładu amplitudy
features.skewness = skewness(signal);

% 8. Kurtoza (kurtosis) - miara "szczytowości" rozkładu sygnału
features.kurtosis = kurtosis(signal);
end