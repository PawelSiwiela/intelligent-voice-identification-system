function [X_train, Y_train, X_test, Y_test] = splitData(X, Y, test_ratio, seed)
% SPLITDATA Dzieli dane na zbiór treningowy i testowy z zachowaniem proporcji klas
%
% Składnia:
%   [X_train, Y_train, X_test, Y_test] = splitData(X, Y, test_ratio, seed)
%
% Argumenty:
%   X - macierz cech [próbki × cechy]
%   Y - macierz etykiet [próbki × kategorie]
%   test_ratio - proporcja danych testowych (domyślnie 0.3)
%   seed - ziarno losowości (domyślnie 42)
%
% Zwraca:
%   X_train - macierz cech treningowych
%   Y_train - macierz etykiet treningowych
%   X_test - macierz cech testowych
%   Y_test - macierz etykiet testowych

% Wartości domyślne
if nargin < 3
    test_ratio = 0.3;
end
if nargin < 4
    seed = 42;
end

% Ustawienie ziarna
rng(seed);

num_samples = size(X, 1);
num_classes = size(Y, 2);

% Inicjalizacja indeksów dla zbiorów treningowego i testowego
train_idx = [];
test_idx = [];

% Dla każdej klasy wykonaj stratyfikowany podział
for class_i = 1:num_classes
    % Znajdź próbki należące do tej klasy
    class_samples = find(Y(:, class_i) == 1);
    num_class_samples = length(class_samples);
    
    if num_class_samples > 0
        % Wymieszaj indeksy dla tej klasy
        shuffled_indices = class_samples(randperm(num_class_samples));
        
        % Podziel próbki klasy na treningowe i testowe
        num_test = max(1, round(num_class_samples * test_ratio));  % Minimum 1 próbka testowa
        num_train = num_class_samples - num_test;
        
        if num_train > 0
            test_class_idx = shuffled_indices(1:num_test);
            train_class_idx = shuffled_indices(num_test+1:end);
            
            % Dołącz do zbiorów treningowych i testowych
            train_idx = [train_idx; train_class_idx];
            test_idx = [test_idx; test_class_idx];
        else
            % Jeśli klasa ma za mało próbek, dodaj co najmniej jedną do treningu
            train_idx = [train_idx; shuffled_indices(1)];
            if length(shuffled_indices) > 1
                test_idx = [test_idx; shuffled_indices(2:end)];
            end
        end
    end
end

% Tworzenie zbiorów treningowych i testowych
X_train = X(train_idx, :);
Y_train = Y(train_idx, :);
X_test = X(test_idx, :);
Y_test = Y(test_idx, :);

% Wyświetl informacje o podziale
fprintf('Stratyfikowany podział danych: %d próbek treningowych, %d próbek testowych\n', ...
    size(X_train, 1), size(X_test, 1));

% Sprawdź reprezentację klas w obu zbiorach
for i = 1:num_classes
    train_count = sum(Y_train(:,i));
    test_count = sum(Y_test(:,i));
    fprintf('  Klasa %d: %d treningowych, %d testowych\n', i, train_count, test_count);
end
end