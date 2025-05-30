function [normalized_data, norm_params] = normalizeFeatures(data_matrix)
% NORMALIZEFEATURES Normalizacja cech do zakresu [-1, 1]
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
%     - scaling_factors: wartości użyte do skalowania każdej cechy
%     - min_values: minimalne wartości po normalizacji
%     - max_values: maksymalne wartości po normalizacji

% Inicjalizacja macierzy wynikowej
normalized_data = zeros(size(data_matrix));

% Parametry normalizacji do późniejszego użycia
norm_params = struct();
scaling_factors = zeros(1, size(data_matrix, 2));

logInfo('🔢 Normalizacja %d cech do zakresu [-1, 1]...', size(data_matrix, 2));

% Normalizacja każdej cechy osobno
for col = 1:size(data_matrix, 2)
    % Pobranie wartości dla aktualnej cechy
    feature_values = data_matrix(:, col);
    
    % Znajdź maksymalną wartość bezwzględną w kolumnie (czynnik skalujący)
    max_abs_value = max(abs(feature_values));
    
    % Zabezpieczenie przed dzieleniem przez zero
    if max_abs_value == 0 || isnan(max_abs_value)
        max_abs_value = eps;  % Najmniejsza dodatnia liczba w MATLAB
        logWarning('⚠️ Cecha %d zawiera tylko zera lub wartości NaN - używam eps jako dzielnik', col);
    end
    
    % Zapisz czynnik skalujący do późniejszego użycia
    scaling_factors(col) = max_abs_value;
    
    % Normalizacja cechy przez maksymalną wartość bezwzględną
    normalized_data(:, col) = feature_values / max_abs_value;
end

% Obsługa wartości nieskończonych i NaN
if any(~isfinite(normalized_data(:)))
    logWarning('⚠️ Wykryto nieskończone wartości po normalizacji - zastępuję zerami');
    
    % Zamiana NaN i Inf na 0
    normalized_data(~isfinite(normalized_data)) = 0;
end

% Obliczenie zakresów po normalizacji
min_values = min(normalized_data, [], 1);
max_values = max(normalized_data, [], 1);

% Zapisanie parametrów normalizacji
norm_params.scaling_factors = scaling_factors;
norm_params.min_values = min_values;
norm_params.max_values = max_values;

logSuccess('✅ Normalizacja zakończona. Zakres wartości: [%.4f, %.4f]', ...
    min(min_values), max(max_values));
end