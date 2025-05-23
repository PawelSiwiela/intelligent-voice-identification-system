function normalized_data = normalizeFeatures(data_matrix)
% Normalizacja wszystkich cech w macierzy danych
%
% Argumenty:
%   data_matrix - macierz gdzie wiersze to próbki, kolumny to cechy
%
% Zwraca:
%   normalized_data - znormalizowana macierz danych

normalized_data = zeros(size(data_matrix));

for col = 1:size(data_matrix, 2)
    feature_values = data_matrix(:, col);
    max_abs_value = max(abs(feature_values));
    
    if max_abs_value == 0
        max_abs_value = eps;
    end
    
    normalized_data(:, col) = feature_values / max_abs_value;
end
end