function validateInputData(X, Y, labels)
% =========================================================================
% WALIDACJA DANYCH WEJŚCIOWYCH DLA GRID SEARCH
% =========================================================================
% Sprawdza poprawność danych przed rozpoczęciem optymalizacji
% AUTOR: Paweł Siwiela, 2025
% =========================================================================

logDebug('🔍 Walidacja danych wejściowych...');

% =========================================================================
% SPRAWDZENIE PODSTAWOWYCH WYMIARÓW
% =========================================================================

if isempty(X) || isempty(Y)
    error('❌ Dane wejściowe X lub Y są puste');
end

[num_samples_X, num_features] = size(X);
[num_samples_Y, num_classes] = size(Y);

% Sprawdzenie zgodności liczby próbek
if num_samples_X ~= num_samples_Y
    error('❌ Liczba próbek w X (%d) nie zgadza się z Y (%d)', num_samples_X, num_samples_Y);
end

% Sprawdzenie zgodności liczby klas
if length(labels) ~= num_classes
    error('❌ Liczba etykiet (%d) nie zgadza się z liczbą klas w Y (%d)', length(labels), num_classes);
end

% =========================================================================
% SPRAWDZENIE TYPU I WARTOŚCI DANYCH
% =========================================================================

if ~isnumeric(X) || ~isnumeric(Y)
    error('❌ Macierze X i Y muszą być numeryczne');
end

% Sprawdzenie NaN i Inf
if any(isnan(X(:))) || any(isinf(X(:)))
    error('❌ Macierz X zawiera wartości NaN lub Inf');
end

if any(isnan(Y(:))) || any(isinf(Y(:)))
    error('❌ Macierz Y zawiera wartości NaN lub Inf');
end

% =========================================================================
% SPRAWDZENIE FORMATU ONE-HOT
% =========================================================================

% Sprawdzenie czy Y to one-hot encoding
Y_sums = sum(Y, 2);
if ~all(abs(Y_sums - 1) < 1e-10)
    logWarning('⚠️ Y może nie być w formacie one-hot encoding');
end

% Sprawdzenie czy każda klasa ma próbki
class_counts = sum(Y, 1);
empty_classes = find(class_counts == 0);
if ~isempty(empty_classes)
    logWarning('⚠️ Niektóre klasy nie mają próbek');
end

% =========================================================================
% SPRAWDZENIE WYMAGAŃ DLA CV
% =========================================================================

min_samples_per_class = min(class_counts);
if min_samples_per_class < 3
    logWarning('⚠️ Niektóre klasy mają <3 próbki - może wpłynąć na cross-validation');
end

if num_samples_X < 10
    logWarning('⚠️ Bardzo mało próbek (%d) - wyniki mogą być niewiarygodne', num_samples_X);
end

% =========================================================================
% PODSUMOWANIE
% =========================================================================

logSuccess('✅ Walidacja danych zakończona pomyślnie');
logDebug('📊 Próbki: %d, Cechy: %d, Klasy: %d', num_samples_X, num_features, num_classes);
logDebug('📊 Min/Max próbek per klasa: %d/%d', min(class_counts), max(class_counts));

end