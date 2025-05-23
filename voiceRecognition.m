close all;
clear all;
clc;

% Parametry
noise_level = 0.1; % Poziom szumu (10% amplitudy sygnału)

% Przygotowanie danych uczących
num_samples = 10;
vowels = {'a', 'e', 'i'};
num_vowels = length(vowels);

% Inicjalizacja macierzy cech
X = [];  % Macierz cech
Y = [];  % Etykiety (one-hot encoding)

% Sprawdzenie istnienia folderu głównego
current_file_path = mfilename('fullpath');
[current_dir, ~, ~] = fileparts(current_file_path);
[parent_dir, ~, ~] = fileparts(current_dir);
base_path = fullfile(parent_dir, 'dźwięki proste');

if ~exist(base_path, 'dir')
    error('Folder "%s" nie został znaleziony!', base_path);
end

% Liczniki udanych wczytań
successful_loads = 0;
failed_loads = 0;

% Utworzenie głównego paska postępu
total_samples = num_vowels * num_samples;
h_main = waitbar(0, 'Rozpoczynam przetwarzanie próbek...', ...
    'Name', 'Postęp przetwarzania');
sample_count = 0;

% Wczytanie i przetworzenie wszystkich próbek
for v = 1:num_vowels
    vowel = vowels{v};
    vowel_path = fullfile(base_path, vowel, [vowel ' - normalnie']);
    
    if ~exist(vowel_path, 'dir')
        warning('Folder "%s" nie istnieje. Pomijam samogłoskę %s.', vowel_path, vowel);
        continue;
    end
    
    for i = 1:num_samples
        % Aktualizacja paska postępu
        sample_count = sample_count + 1;
        waitbar(sample_count/total_samples, h_main, ...
            sprintf('Przetwarzanie: %s, próbka %d/%d (Postęp: %.1f%%)', ...
            vowel, i, num_samples, 100*sample_count/total_samples));
        
        % Pełna ścieżka do pliku
        file_path = fullfile(vowel_path, sprintf('Dźwięk %d.wav', i));
        
        try
            % Ekstrakcja cech
            [features, feature_names] = preprocessAudio(file_path, noise_level);
            
            % Dodanie do macierzy cech
            X = [X; features];
            
            % Utworzenie etykiety one-hot
            label = zeros(1, num_vowels);
            label(v) = 1;
            Y = [Y; label];
            
            successful_loads = successful_loads + 1;
        catch ME
            failed_loads = failed_loads + 1;
            warning('Problem z przetworzeniem pliku %s: %s', file_path, ME.message);
            continue;
        end
    end
end

% Zamknięcie głównego paska postępu
close(h_main);

% Sprawdzenie czy mamy wystarczająco danych
if successful_loads < 10
    warning('Zbyt mało próbek do analizy! Wczytano tylko %d próbek.', successful_loads);
end

fprintf('\nStatystyki wczytywania:\n');
fprintf('Udane wczytania: %d\n', successful_loads);
fprintf('Nieudane wczytania: %d\n', failed_loads);

% Kontynuuj tylko jeśli mamy dane
if ~isempty(X)
    % Normalizacja wszystkich cech razem
    X = normalizeFeatures(X);
    
    % Podział na zbiór treningowy i testowy (80/20)
    cv = cvpartition(size(X,1), 'HoldOut', 0.2);
    X_train = X(cv.training,:);
    Y_train = Y(cv.training,:);
    X_test = X(cv.test,:);
    Y_test = Y(cv.test,:);
    
    % Zapisanie danych
    save('preprocessed_data.mat', 'X_train', 'Y_train', 'X_test', 'Y_test', ...
        'feature_names', 'vowels', 'successful_loads', 'failed_loads');
    
    % Wizualizacja
    figure;
    boxplot(X, 'Labels', feature_names);
    title('Rozkład znormalizowanych cech');
    xlabel('Cecha');
    ylabel('Wartość');
    set(gca, 'XTickLabelRotation', 45);
    grid on;
    
    % Wyświetlenie informacji o danych
    fprintf('\nInformacje o danych:\n');
    fprintf('Liczba cech: %d\n', length(feature_names));
    fprintf('Liczba próbek treningowych: %d\n', size(X_train, 1));
    fprintf('Liczba próbek testowych: %d\n', size(X_test, 1));
    
    % Tworzenie sieci neuronowej
    net = patternnet([15 8]); % Sieć z dwoma warstwami ukrytymi (15 i 8 neuronów)
    net.divideFcn = ''; % Wyłączenie automatycznego podziału danych
    net.trainParam.epochs = 1500; % Więcej epok
    net.trainParam.goal = 1e-7; % Niższy próg błędu
    net.trainParam.min_grad = 1e-6;
    
    % Trenowanie sieci
    fprintf('\nRozpoczynam trenowanie sieci...\n');
    [net, tr] = train(net, X_train', Y_train');
    
    % Testowanie sieci
    Y_pred = net(X_test')';
    
    % Konwersja wyników na etykiety
    [~, predicted_labels] = max(Y_pred, [], 2);
    [~, true_labels] = max(Y_test, [], 2);
    
    % Obliczanie dokładności
    accuracy = sum(predicted_labels == true_labels) / length(true_labels);
    
    % Macierz pomyłek
    cm = confusionmat(true_labels, predicted_labels);
    
    % Wyświetlenie wyników
    fprintf('\nWyniki klasyfikacji:\n');
    fprintf('Dokładność: %.2f%%\n', accuracy * 100);
    
    % Wizualizacja wyników
    figure;
    
    % Macierz pomyłek
    subplot(2,2,1);
    confusionchart(cm, vowels);
    title('Macierz pomyłek');
    
    % Historia uczenia
    subplot(2,2,2);
    plot(tr.perf);
    title('Krzywa uczenia');
    xlabel('Epoka');
    ylabel('MSE');
    grid on;
    
    % Wartości wyjściowe dla zbioru testowego
    subplot(2,2,3);
    plot(Y_pred, 'o-');
    hold on;
    plot(Y_test, 'x-');
    title('Porównanie wyników - zbiór testowy');
    xlabel('Próbka');
    ylabel('Wartość wyjściowa');
    legend('Przewidywane', 'Rzeczywiste');
    grid on;
    
    % Zapisanie wytrenowanej sieci
    save('trained_network.mat', 'net', 'tr', 'accuracy', 'cm');
    
    % Szczegółowe statystyki dla każdej klasy
    fprintf('\nStatystyki dla poszczególnych samogłosek:\n');
    for i = 1:length(vowels)
        precision = cm(i,i) / sum(cm(:,i));
        recall = cm(i,i) / sum(cm(i,:));
        f1_score = 2 * (precision * recall) / (precision + recall);
        
        fprintf('\nSamogłoska "%s":\n', vowels{i});
        fprintf('Precyzja: %.2f%%\n', precision * 100);
        fprintf('Czułość: %.2f%%\n', recall * 100);
        fprintf('F1-Score: %.2f%%\n', f1_score * 100);
    end
else
    error('Nie udało się wczytać żadnych danych!');
end