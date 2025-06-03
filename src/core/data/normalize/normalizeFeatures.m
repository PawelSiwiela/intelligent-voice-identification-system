function [normalized_data, norm_params] = normalizeFeatures(data_matrix)
% NORMALIZEFEATURES Normalizacja cech do zakresu [-1, 1] (min-max)
%
% Składnia:
%   [normalized_data, norm_params] = normalizeFeatures(data_matrix)
%
% Argumenty:
%   data_matrix - macierz danych [próbki × cechy]
%
% Zwraca:
%   normalized_data - znormalizowana macierz [próbki × cechy]
%   norm_params - struktura zawierająca parametry normalizacji (do późniejszego użycia)
%     - min_values: minimalne wartości cech
%     - max_values: maksymalne wartości cech

% Inicjalizacja macierzy wynikowej
normalized_data = zeros(size(data_matrix));

% Parametry normalizacji do późniejszego użycia
norm_params = struct();
min_values = zeros(1, size(data_matrix, 2));
max_values = zeros(1, size(data_matrix, 2));

logInfo('🔢 Normalizacja %d cech do zakresu [-1, 1] (min-max)...', size(data_matrix, 2));

% Normalizacja każdej cechy osobno
for col = 1:size(data_matrix, 2)
    feature_values = data_matrix(:, col);
    
    feat_min = min(feature_values);
    feat_max = max(feature_values);
    
    % Zabezpieczenie przed dzieleniem przez zero
    if feat_max == feat_min
        feat_max = feat_min + eps; % Unikamy dzielenia przez zero
        logWarning('⚠️ Cecha %d ma stałą wartość - używam eps jako dzielnik', col);
    end
    
    min_values(col) = feat_min;
    max_values(col) = feat_max;
    
    % Normalizacja min-max do zakresu [-1, 1]
    normalized_data(:, col) = 2 * (feature_values - feat_min) / (feat_max - feat_min) - 1;
end

% Obsługa wartości nieskończonych i NaN
if any(~isfinite(normalized_data(:)))
    logWarning('⚠️ Wykryto nieskończone wartości po normalizacji - zastępuję zerami');
    normalized_data(~isfinite(normalized_data)) = 0;
end

% Zapisanie parametrów normalizacji
norm_params.min_values = min_values;
norm_params.max_values = max_values;

logSuccess('✅ Normalizacja zakończona. Zakres wartości: [%.4f, %.4f]', ...
    min(normalized_data(:)), max(normalized_data(:)));
end