function [net, results] = trainNeuralNetwork(X, Y, labels, varargin)
% Funkcja do trenowania sieci neuronowej dla rozpoznawania głosu
%
% Argumenty:
%   X - macierz cech (próbki x cechy)
%   Y - macierz etykiet (one-hot encoding)
%   labels - nazwy kategorii
%   varargin - opcjonalne parametry:
%     'HiddenLayers' - rozmiary warstw ukrytych (domyślnie [15 8])
%     'Epochs' - liczba epok (domyślnie 1500)
%     'Goal' - próg błędu (domyślnie 1e-7)
%     'TestRatio' - procent danych testowych (domyślnie 0.2)
%     'TestSamplesPerCategory' - liczba próbek testowych na kategorię (domyślnie 2)
%     'SaveResults' - czy zapisać wyniki (domyślnie true)
%     'ShowPlots' - czy pokazać wykresy (domyślnie true)
%
% Zwraca:
%   net - wytrenowana sieć neuronowa
%   results - struktura z wynikami trenowania

% Parsowanie argumentów opcjonalnych
p = inputParser;
addParameter(p, 'HiddenLayers', [15 8], @(x) isnumeric(x) && all(x > 0));
addParameter(p, 'Epochs', 1500, @(x) isnumeric(x) && x > 0);
addParameter(p, 'Goal', 1e-7, @(x) isnumeric(x) && x > 0);
addParameter(p, 'TestRatio', 0.2, @(x) isnumeric(x) && x >= 0 && x <= 1);
addParameter(p, 'TestSamplesPerCategory', 2, @(x) isnumeric(x) && x >= 1);
addParameter(p, 'SaveResults', true, @islogical);
addParameter(p, 'ShowPlots', true, @islogical);
parse(p, varargin{:});

hidden_layers = p.Results.HiddenLayers;
epochs = p.Results.Epochs;
goal = p.Results.Goal;
test_ratio = p.Results.TestRatio;
test_samples_per_category = p.Results.TestSamplesPerCategory;
save_results = p.Results.SaveResults;
show_plots = p.Results.ShowPlots;

fprintf('Rozpoczęcie trenowania sieci neuronowej...\n');
fprintf('Parametry:\n');
fprintf('  - Warstwy ukryte: [%s]\n', num2str(hidden_layers));
fprintf('  - Epoki: %d\n', epochs);
fprintf('  - Próg błędu: %.2e\n', goal);
fprintf('  - Procent danych testowych: %.1f%%\n', test_ratio * 100);

% Podział na zbiór treningowy i testowy - STRATYFIKOWANY
if test_ratio > 0
    num_samples = size(X, 1);
    % Obliczenie liczby próbek testowych na kategorię
    samples_per_test = test_samples_per_category;
    
    fprintf('\nPodział stratyfikowany: %d próbek testowych na kategorię\n', samples_per_test);
    
    % Inicjalizacja indeksów
    train_indices = [];
    test_indices = [];
    
    % Dla każdej kategorii wybierz próbki
    for cat = 1:length(labels)
        % Znajdź wszystkie próbki tej kategorii
        category_indices = find(Y(:, cat) == 1);
        
        if length(category_indices) < samples_per_test
            warning('Kategoria "%s" ma tylko %d próbek, ale potrzeba %d dla testu', ...
                labels{cat}, length(category_indices), samples_per_test);
            samples_for_this_cat = length(category_indices);
        else
            samples_for_this_cat = samples_per_test;
        end
        
        % Losowy wybór próbek testowych dla tej kategorii
        if samples_for_this_cat > 0
            test_idx = randperm(length(category_indices), samples_for_this_cat);
            test_indices = [test_indices; category_indices(test_idx)];
            
            % Pozostałe próbki idą do zbioru treningowego
            train_idx = setdiff(1:length(category_indices), test_idx);
            train_indices = [train_indices; category_indices(train_idx)];
        end
    end
    
    % Utworzenie zbiorów danych
    X_train = X(train_indices, :);
    Y_train = Y(train_indices, :);
    X_test = X(test_indices, :);
    Y_test = Y(test_indices, :);
    
    fprintf('\nInformacje o zbiorach danych:\n');
    fprintf('Liczba próbek treningowych: %d\n', size(X_train, 1));
    fprintf('Liczba próbek testowych: %d\n', size(X_test, 1));
    
    % Sprawdzenie reprezentacji kategorii w zbiorze testowym
    fprintf('\nRozkład kategorii w zbiorze testowym:\n');
    for cat = 1:length(labels)
        count = sum(Y_test(:, cat));
        fprintf('  %s: %d próbek\n', labels{cat}, count);
    end
    
else
    % Brak podziału - trenowanie na wszystkich danych
    X_train = X;
    Y_train = Y;
    X_test = [];
    Y_test = [];
    
    fprintf('\nTrenowanie na wszystkich danych (%d próbek)\n', size(X_train, 1));
end

% Tworzenie sieci neuronowej
net = patternnet(hidden_layers);
net.divideFcn = '';  % Wyłączenie automatycznego podziału danych
net.trainParam.epochs = epochs;
net.trainParam.goal = goal;
net.trainParam.min_grad = 1e-6;

% Trenowanie sieci
fprintf('\nRozpoczynam trenowanie sieci...\n');
training_start = tic;
[net, tr] = train(net, X_train', Y_train');
training_time = toc(training_start);
fprintf('Czas trenowania sieci: %.2f sekund (%.2f minut)\n', training_time, training_time/60);

% Inicjalizacja struktury wyników
results = struct();
results.training_time = training_time;
results.training_record = tr;
results.network_config = struct('hidden_layers', hidden_layers, 'epochs', epochs, 'goal', goal);

% Testowanie sieci (jeśli są dane testowe)
if ~isempty(X_test)
    fprintf('\nTestowanie sieci...\n');
    testing_start = tic;
    Y_pred = net(X_test')';
    [~, predicted_labels] = max(Y_pred, [], 2);
    [~, true_labels] = max(Y_test, [], 2);
    accuracy = sum(predicted_labels == true_labels) / length(true_labels);
    testing_time = toc(testing_start);
    
    % Macierz pomyłek
    cm = confusionmat(true_labels, predicted_labels);
    
    % Zapisanie wyników testowania
    results.testing_time = testing_time;
    results.accuracy = accuracy;
    results.confusion_matrix = cm;
    results.predicted_labels = predicted_labels;
    results.true_labels = true_labels;
    results.Y_pred = Y_pred;
    results.Y_test = Y_test;
    
    fprintf('Czas testowania sieci: %.2f sekund\n', testing_time);
    fprintf('\nWyniki klasyfikacji:\n');
    fprintf('Dokładność: %.2f%%\n', accuracy * 100);
    
    % Szczegółowe statystyki dla każdej kategorii
    fprintf('\nStatystyki dla poszczególnych kategorii:\n');
    for i = 1:length(labels)
        if i <= size(cm, 1) && i <= size(cm, 2) && sum(cm(:,i)) > 0 && sum(cm(i,:)) > 0
            precision = cm(i,i) / sum(cm(:,i));
            recall = cm(i,i) / sum(cm(i,:));
            if (precision + recall) > 0
                f1_score = 2 * (precision * recall) / (precision + recall);
            else
                f1_score = 0;
            end
            
            fprintf('Kategoria "%s": Precyzja=%.2f%%, Czułość=%.2f%%, F1=%.2f%%\n', ...
                labels{i}, precision*100, recall*100, f1_score*100);
        end
    end
    
    % Wizualizacja wyników
    if show_plots
        createResultsPlots(results, labels);
    end
else
    fprintf('\nBrak danych testowych - pominięto testowanie.\n');
end

% Zapisanie wyników
if save_results
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    filename = sprintf('trained_network_%s.mat', timestamp);
    
    save(filename, 'net', 'results', 'labels');
    fprintf('\nSieć została zapisana do pliku: %s\n', filename);
end

end

function createResultsPlots(results, labels)
% Funkcja pomocnicza do tworzenia wykresów wyników

figure('Name', 'Wyniki trenowania sieci neuronowej', 'Position', [100 100 1200 800]);

% Macierz pomyłek
subplot(2,2,1);
if ~isempty(results.confusion_matrix)
    confusionchart(results.confusion_matrix, labels);
    title('Macierz pomyłek');
end

% Historia uczenia
subplot(2,2,2);
if isfield(results.training_record, 'perf')
    plot(results.training_record.perf);
    title('Krzywa uczenia');
    xlabel('Epoka');
    ylabel('MSE');
    grid on;
end

% Porównanie wyników (jeśli są dostępne)
if isfield(results, 'Y_pred') && isfield(results, 'Y_test')
    subplot(2,2,3);
    plot(results.Y_pred, 'o-', 'MarkerSize', 3);
    hold on;
    plot(results.Y_test, 'x-', 'MarkerSize', 3);
    title('Porównanie wyników - zbiór testowy');
    xlabel('Próbka');
    ylabel('Wartość wyjściowa');
    legend('Przewidywane', 'Rzeczywiste');
    grid on;
end

% Rozkład dokładności (jeśli są dostępne)
if isfield(results, 'confusion_matrix') && ~isempty(results.confusion_matrix)
    subplot(2,2,4);
    cm = results.confusion_matrix;
    accuracies_per_class = diag(cm) ./ sum(cm, 2);
    accuracies_per_class(isnan(accuracies_per_class)) = 0;  % Obsługa dzielenia przez zero
    
    bar(accuracies_per_class * 100);
    title('Dokładność dla każdej kategorii');
    xlabel('Kategoria');
    ylabel('Dokładność (%)');
    if length(labels) <= 20  % Pokaż etykiety tylko jeśli nie ma ich zbyt wiele
        xticks(1:length(labels));
        xticklabels(labels);
        xtickangle(45);
    end
    grid on;
end

end