close all;
clear all;
clc;

% Parametry
noise_level = 0.1;
num_samples = 10;

% Definicja kategorii dźwięków
use_vowels = false;    % Ustaw false aby wyłączyć analizę samogłosek
use_complex = true;   % Ustaw false aby wyłączyć analizę par słów

% Samogłoski
vowels = {'a', 'e', 'i'};
num_vowels = length(vowels);

% Pary słów
complex_commands = {
    'Drzwi/Otwórz drzwi', 'Drzwi/Zamknij drzwi', ...
    'Odbiornik/Włącz odbiornik', 'Odbiornik/Wyłącz odbiornik', ...
    'Światło/Włącz światło', 'Światło/Wyłącz światło', ...
    'Temperatura/Zmniejsz temperaturę', 'Temperatura/Zwiększ temperaturę'
    };
num_commands = length(complex_commands);

% Określenie całkowitej liczby kategorii
if use_vowels && use_complex
    total_categories = num_vowels + num_commands;
    labels = [vowels, complex_commands];
elseif use_vowels
    total_categories = num_vowels;
    labels = vowels;
else
    total_categories = num_commands;
    labels = complex_commands;
end

% Inicjalizacja macierzy cech
X = [];  % Macierz cech
Y = [];  % Etykiety (one-hot encoding)

% Sprawdzenie istnienia folderów
current_file_path = mfilename('fullpath');
[current_dir, ~, ~] = fileparts(current_file_path);
simple_path = fullfile(current_dir, 'data', 'simple');
complex_path = fullfile(current_dir, 'data', 'complex');

% Liczniki udanych wczytań
successful_loads = 0;
failed_loads = 0;

% Utworzenie głównego paska postępu
total_samples = ((use_vowels * num_vowels) + (use_complex * num_commands)) * num_samples;
h_main = waitbar(0, 'Rozpoczynam przetwarzanie próbek...', 'Name', 'Postęp przetwarzania');
sample_count = 0;

% Na początku pliku, po inicjalizacji
total_time_start = tic; % Start pomiaru całkowitego czasu

% Wczytanie samogłosek
if use_vowels
    if ~exist(simple_path, 'dir')
        error('Folder z samogłoskami nie został znaleziony! Ścieżka: %s', simple_path);
    end
    
    for v = 1:num_vowels
        vowel = vowels{v};
        vowel_path = fullfile(simple_path, vowel, [vowel ' - normalnie']);
        
        if ~exist(vowel_path, 'dir')
            warning('Folder "%s" nie istnieje. Pomijam samogłoskę %s.', vowel_path, vowel);
            continue;
        end
        
        for i = 1:num_samples
            % Aktualizacja paska postępu
            sample_count = sample_count + 1;
            waitbar(sample_count/total_samples, h_main, ...
                sprintf('Przetwarzanie samogłoski: %s, próbka %d/%d (Postęp: %.1f%%)', ...
                vowel, i, num_samples, 100*sample_count/total_samples));
            
            % Pełna ścieżka do pliku
            file_path = fullfile(vowel_path, sprintf('Dźwięk %d.wav', i));
            
            try
                [features, feature_names] = preprocessAudio(file_path, noise_level);
                X = [X; features];
                label = zeros(1, total_categories);
                label(v) = 1;
                Y = [Y; label];
                successful_loads = successful_loads + 1;
            catch ME
                failed_loads = failed_loads + 1;
                warning('Problem z przetworzeniem pliku %s: %s', file_path, ME.message);
            end
        end
    end
end

% Wczytanie par słów
if use_complex
    if ~exist(complex_path, 'dir')
        error('Folder z komendami złożonymi nie został znaleziony! Ścieżka: %s', complex_path);
    end
    
    for c = 1:num_commands
        command_parts = strsplit(complex_commands{c}, '/');
        command_path = fullfile(complex_path, command_parts{1}, command_parts{2}, 'normalnie');
        
        if ~exist(command_path, 'dir')
            warning('Folder "%s" nie istnieje. Pomijam komendę %s.', command_path, complex_commands{c});
            continue;
        end
        
        for i = 1:num_samples
            % Aktualizacja paska postępu
            sample_count = sample_count + 1;
            waitbar(sample_count/total_samples, h_main, ...
                sprintf('Przetwarzanie komendy: %s, próbka %d/%d (Postęp: %.1f%%)', ...
                complex_commands{c}, i, num_samples, 100*sample_count/total_samples));
            
            % Pełna ścieżka do pliku
            file_path = fullfile(command_path, sprintf('Dźwięk %d.wav', i));
            
            try
                [features, feature_names] = preprocessAudio(file_path, noise_level);
                X = [X; features];
                label = zeros(1, total_categories);
                label(num_vowels + c) = 1;
                Y = [Y; label];
                successful_loads = successful_loads + 1;
            catch ME
                failed_loads = failed_loads + 1;
                warning('Problem z przetworzeniem pliku %s: %s', file_path, ME.message);
            end
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
    
    % Po inicjalizacji macierzy cech
    fprintf('\nRozpoczęcie przetwarzania...\n');
    preprocessing_time_start = tic; % Start pomiaru czasu preprocessingu

    % Trenowanie sieci
    fprintf('\nRozpoczynam trenowanie sieci...\n');
    [net, tr] = train(net, X_train', Y_train');
    
    % Po zakończeniu wczytywania próbek
    preprocessing_time = toc(preprocessing_time_start);
    fprintf('\nCzas przetwarzania wstępnego: %.2f sekund (%.2f minut)\n', ...
        preprocessing_time, preprocessing_time/60);
    
    % Przed treningiem sieci
    training_time_start = tic; % Start pomiaru czasu treningu
    fprintf('\nRozpoczynam trenowanie sieci...\n');
    
    [net, tr] = train(net, X_train', Y_train');
    
    training_time = toc(training_time_start);
    fprintf('Czas trenowania sieci: %.2f sekund (%.2f minut)\n', ...
        training_time, training_time/60);
    
    % Przed testowaniem sieci
    testing_time_start = tic; % Start pomiaru czasu testowania
    fprintf('\nTestowanie sieci...\n');
    
    Y_pred = net(X_test')';
    [~, predicted_labels] = max(Y_pred, [], 2);
    [~, true_labels] = max(Y_test, [], 2);
    accuracy = sum(predicted_labels == true_labels) / length(true_labels);
    
    testing_time = toc(testing_time_start);
    fprintf('Czas testowania sieci: %.2f sekund\n', testing_time);
    
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
    confusionchart(cm, labels);
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
    save('trained_network.mat', 'net', 'tr', 'accuracy', 'cm', ...
        'preprocessing_time', 'training_time', 'testing_time', 'total_time');
    
    % Szczegółowe statystyki dla każdej klasy
    fprintf('\nStatystyki dla poszczególnych kategorii:\n');
    for i = 1:length(labels)
        precision = cm(i,i) / sum(cm(:,i));
        recall = cm(i,i) / sum(cm(i,:));
        f1_score = 2 * (precision * recall) / (precision + recall);
        
        fprintf('\nKategoria "%s":\n', labels{i});
        fprintf('Precyzja: %.2f%%\n', precision * 100);
        fprintf('Czułość: %.2f%%\n', recall * 100);
        fprintf('F1-Score: %.2f%%\n', f1_score * 100);
    end
else
    error('Nie udało się wczytać żadnych danych!');
end

% Na końcu pliku, przed końcowym else
total_time = toc(total_time_start);
fprintf('\nStatystyki czasowe:\n');
fprintf('Całkowity czas wykonania: %.2f sekund (%.2f minut)\n', ...
    total_time, total_time/60);
fprintf('  - Przetwarzanie wstępne: %.2f sekund (%.1f%%)\n', ...
    preprocessing_time, 100*preprocessing_time/total_time);
fprintf('  - Trening sieci: %.2f sekund (%.1f%%)\n', ...
    training_time, 100*training_time/total_time);
fprintf('  - Testowanie: %.2f sekund (%.1f%%)\n', ...
    testing_time, 100*testing_time/total_time);