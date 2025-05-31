function [X_train, Y_train, X_val, Y_val, X_test, Y_test] = splitData(X, Y, val_ratio, test_ratio)
% SPLITDATA Dzieli dane na zbiory treningowy, walidacyjny i testowy z zachowaniem stratyfikacji
%
% Składnia:
%   [X_train, Y_train, X_val, Y_val, X_test, Y_test] = splitData(X, Y, val_ratio, test_ratio)
%
% Argumenty:
%   X - macierz cech [próbki × cechy]
%   Y - macierz etykiet [próbki × klasy] (one-hot encoding)
%   val_ratio - stosunek zbioru walidacyjnego (np. 0.2 = 20%)
%   test_ratio - stosunek zbioru testowego (np. 0.2 = 20%)
%
% Zwraca:
%   X_train, Y_train - dane treningowe
%   X_val, Y_val - dane walidacyjne
%   X_test, Y_test - dane testowe

if nargin < 4
    test_ratio = val_ratio;  % Domyślnie takie same proporcje dla walidacji i testu
end

% Inicjalizacja pustych zbiorów wynikowych
X_train = [];
Y_train = [];
X_val = [];
Y_val = [];
X_test = [];
Y_test = [];

% Znajdź indeksy próbek dla każdej klasy
[~, max_indices] = max(Y, [], 2);
num_classes = size(Y, 2);

logInfo('🔢 Stratyfikowany podział danych dla %d klas...', num_classes);

% Przejdź przez każdą klasę i podziel jej próbki
for class = 1:num_classes
    % Znajdź wszystkie próbki należące do danej klasy
    class_indices = find(max_indices == class);
    num_samples = length(class_indices);
    
    % Jeśli nie ma próbek tej klasy, przejdź do następnej
    if num_samples == 0
        logWarning('⚠️ Brak próbek dla klasy %d', class);
        continue;
    end
    
    % Ustalenie liczby próbek dla każdego zbioru
    val_size = round(num_samples * val_ratio);
    test_size = round(num_samples * test_ratio);
    train_size = num_samples - val_size - test_size;
    
    % Upewnienie się, że mamy zawsze po 6/2/2 próbek
    if num_samples == 10  % Dla 10 próbek na klasę
        train_size = 6;
        val_size = 2;
        test_size = 2;
    end
    
    % Jeśli mamy za mało próbek, ostrzeż użytkownika
    if num_samples < 10
        logWarning('⚠️ Klasa %d ma tylko %d próbek - nie można uzyskać podziału 6/2/2', class, num_samples);
    end
    
    % Wymieszanie indeksów dla tej klasy
    rng(42+class);  % Deterministyczne ziarno dla powtarzalności
    shuffled_indices = class_indices(randperm(num_samples));
    
    % Przypisanie próbek do odpowiednich zbiorów
    train_idx = shuffled_indices(1:train_size);
    val_idx = shuffled_indices(train_size+1:train_size+val_size);
    test_idx = shuffled_indices(train_size+val_size+1:end);
    
    % Dodanie próbek do odpowiednich zbiorów
    X_train = [X_train; X(train_idx, :)];
    Y_train = [Y_train; Y(train_idx, :)];
    
    X_val = [X_val; X(val_idx, :)];
    Y_val = [Y_val; Y(val_idx, :)];
    
    X_test = [X_test; X(test_idx, :)];
    Y_test = [Y_test; Y(test_idx, :)];
    
    logDebug('  Klasa %d: %d próbek treningowych, %d walidacyjnych, %d testowych', class, length(train_idx), length(val_idx), length(test_idx));
end

% Wymieszanie próbek w ramach każdego zbioru (zachowując pary X-Y)
rng(42);  % Dla powtarzalności
train_perm = randperm(size(X_train, 1));
X_train = X_train(train_perm, :);
Y_train = Y_train(train_perm, :);

val_perm = randperm(size(X_val, 1));
X_val = X_val(val_perm, :);
Y_val = Y_val(val_perm, :);

test_perm = randperm(size(X_test, 1));
X_test = X_test(test_perm, :);
Y_test = Y_test(test_perm, :);

% Wyświetlenie informacji o podziale danych
logInfo('📊 Podział danych: %d próbek treningowych, %d walidacyjnych, %d testowych', ...
    size(X_train, 1), size(X_val, 1), size(X_test, 1));

end