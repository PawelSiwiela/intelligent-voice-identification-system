function normalized_data = normalizeFeatures(data_matrix)
% =========================================================================
% NORMALIZACJA CECH AUDIO
% =========================================================================
% Normalizuje wszystkie cechy w macierzy danych metodą skalowania
% względem maksymalnej wartości bezwzględnej w każdej kolumnie
%
% ARGUMENTY:
%   data_matrix - macierz danych [próbki × cechy]
%
% ZWRACA:
%   normalized_data - znormalizowana macierz [próbki × cechy]
%
% METODA NORMALIZACJI:
%   Każda cecha jest skalowana przez jej maksymalną wartość bezwzględną,
%   co zapewnia zakres wartości [-1, 1] dla każdej cechy
% =========================================================================

% Inicjalizacja macierzy wynikowej
normalized_data = zeros(size(data_matrix));

% =========================================================================
% NORMALIZACJA KAŻDEJ CECHY OSOBNO
% =========================================================================

for col = 1:size(data_matrix, 2)
    % Pobranie wartości dla aktualnej cechy
    feature_values = data_matrix(:, col);
    
    % Znajdź maksymalną wartość bezwzględną w kolumnie
    max_abs_value = max(abs(feature_values));
    
    % Zabezpieczenie przed dzieleniem przez zero
    if max_abs_value == 0
        max_abs_value = eps;  % Najmniejsza dodatnia liczba w MATLAB
        warning('Cecha %d zawiera tylko zera - używam eps jako dzielnik', col);
    end
    
    % Normalizacja cechy przez maksymalną wartość bezwzględną
    normalized_data(:, col) = feature_values / max_abs_value;
end

% =========================================================================
% WALIDACJA WYNIKÓW
% =========================================================================

% Sprawdzenie czy wszystkie wartości są skończone
if any(~isfinite(normalized_data(:)))
    warning('Wykryto nieskończone wartości po normalizacji');
    
    % Zamiana NaN i Inf na 0
    normalized_data(~isfinite(normalized_data)) = 0;
end

% Informacja o zakresach znormalizowanych cech
min_vals = min(normalized_data, [], 1);
max_vals = max(normalized_data, [], 1);

fprintf('📊 Zakres znormalizowanych cech: [%.3f, %.3f]\n', ...
    min(min_vals), max(max_vals));

end
