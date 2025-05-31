function [best_net, best_tr, optimization_results] = randomSearchOptimizer(X, Y, labels, config)
% RANDOMSEARCHOPTIMIZER Optymalizacja parametrów sieci metodą random search
%
% Składnia:
%   [best_net, best_tr, optimization_results] = randomSearchOptimizer(X, Y, labels, config)
%
% Argumenty:
%   X - macierz cech [próbki × cechy]
%   Y - macierz etykiet [próbki × kategorie] (one-hot encoding)
%   labels - nazwy kategorii (cell array)
%   config - struktura konfiguracyjna
%
% Zwraca:
%   best_net - najlepsza sieć neuronowa
%   best_tr - dane z procesu treningu najlepszej sieci
%   optimization_results - wyniki optymalizacji

% Parametry domyślne
if nargin < 4
    config = struct();
end

if ~isfield(config, 'max_trials')
    config.max_trials = 20;
end

if ~isfield(config, 'golden_accuracy')
    config.golden_accuracy = 0.95;
end

if ~isfield(config, 'early_stopping')
    config.early_stopping = true;
end

% Sprawdź czy mamy określone typy sieci do optymalizacji
if ~isfield(config, 'network_types') || isempty(config.network_types)
    net_types = {'patternnet', 'feedforwardnet'};  % Domyślnie szukamy w obu typach
    logInfo('🔍 Optymalizacja dla typów sieci: patternnet i feedforwardnet');
else
    net_types = config.network_types;
    logInfo('🔍 Optymalizacja ograniczona do typów sieci: %s', strjoin(net_types, ', '));
end

% Zakresy parametrów do przeszukiwania
learning_rates = [0.001, 0.002, 0.003, 0.005, 0.008, 0.01, 0.015, 0.02, 0.05, 0.1];

% Dostosowanie parametrów do scenariusza
switch config.scenario
    case 'vowels'
        % Scenariusz tylko samogłoski - mniej złożony problem, potrzebujemy mniejszych sieci
        logInfo('🔧 Konfiguracja optymalizacji dla SAMOGŁOSEK');
        hidden_layers = {[5], [10], [15], [5 3], [10 5], [15 7]}; % Mniejsze sieci
        training_algs = {'trainscg', 'traingdx', 'trainrp'}; % Szybsze algorytmy
        activation_functions = {'logsig', 'tansig'};
        epochs_range = [100, 150, 200];
        
    case 'commands'
        % Scenariusz tylko komendy złożone - średnio złożony problem
        logInfo('🔧 Konfiguracja optymalizacji dla KOMEND ZŁOŻONYCH');
        hidden_layers = {[10], [20], [30], [10 5], [20 10], [30 15]}; % Średnie sieci
        training_algs = {'trainscg', 'trainlm', 'traingdx', 'trainbfg'}; % Różne algorytmy
        activation_functions = {'logsig', 'tansig'};
        epochs_range = [150, 200, 300];
        
    case 'all'
        % Scenariusz wszystkie dane - najbardziej złożony problem
        logInfo('🔧 Konfiguracja optymalizacji dla WSZYSTKICH DANYCH');
        hidden_layers = {[12], [13], [14], [15], [16], [17], [18]};
        training_algs = {'trainlm', 'trainbr', 'traingdx'}; % Wszystkie algorytmy
        activation_functions = {'logsig'};
        epochs_range = [100, 150, 200];
        
    otherwise
        % Domyślne parametry
        logWarning('⚠️ Nieznany scenariusz: %s. Używam domyślnych parametrów.', config.scenario);
        hidden_layers = {[10], [20], [30], [10 5], [20 10], [30 15]};
        training_algs = {'trainscg', 'trainlm', 'traingdx'};
        activation_functions = {'logsig'};
        epochs_range = [200, 300];
end

% Informacje o danych
num_samples = size(X, 1);
num_features = size(X, 2);
num_classes = size(Y, 2);

logInfo('📊 Dane: %d próbek, %d cech, %d klas', num_samples, num_features, num_classes);

% Inicjalizacja zmiennych do śledzenia najlepszych wyników
best_accuracy = 0;
best_net = [];
best_tr = [];
best_params = struct();
best_training_time = Inf;
golden_found = false;

% Wynik optymalizacji
optimization_results = struct(...
    'trials', struct([]), ...
    'best_accuracy', 0, ...
    'best_params', struct(), ...
    'best_training_time', Inf, ...
    'golden_found', false, ...
    'golden_trial', 0);

% Ustawienie ziarna losowego dla powtarzalności
rng(42);

% Pętla random search
for trial = 1:config.max_trials
    % Losowy wybór parametrów
    net_type = net_types{randi(length(net_types))};
    hidden = hidden_layers{randi(length(hidden_layers))};
    alg = training_algs{randi(length(training_algs))};
    activation = activation_functions{randi(length(activation_functions))};
    learning_rate = learning_rates(randi(length(learning_rates)));
    max_epochs = epochs_range(randi(length(epochs_range)));
    
    % Nazwanie próby
    trial_name = sprintf('%s_%s_%s_%s', net_type, mat2str(hidden), alg, activation);
    
    logInfo('🔄 Próba %d/%d: %s (lr=%.5f, epoki=%d)', trial, config.max_trials, trial_name, learning_rate, max_epochs);
    
    % Konfiguracja dla tworzenia sieci
    network_config = struct(...
        'type', net_type, ...
        'hidden_layers', hidden, ...
        'training_algorithm', alg, ...
        'activation_function', activation);
    
    try
        % Utworzenie sieci
        net = createNetwork(size(X, 2), size(Y, 2), network_config);
        
        % Konfiguracja treningu
        training_config = struct(...
            'learning_rate', learning_rate, ...
            'max_epochs', max_epochs, ...
            'validation_checks', 15, ...
            'show_progress', false, ...
            'show_command_line', false);
        
        % Trenowanie sieci
        tic;
        [net, tr, training_results] = trainNetwork(net, X, Y, training_config);
        training_time = toc;
        
        % Zapisz wyniki próby
        accuracy = training_results.accuracy;
        
        optimization_results.trials(trial).params = network_config;
        optimization_results.trials(trial).accuracy = accuracy;
        optimization_results.trials(trial).training_time = training_time;
        optimization_results.trials(trial).name = trial_name;
        optimization_results.trials(trial).learning_rate = learning_rate;
        optimization_results.trials(trial).max_epochs = max_epochs;
        
        % Aktualizacja najlepszego wyniku
        if accuracy > best_accuracy || (accuracy == best_accuracy && training_time < best_training_time)
            best_accuracy = accuracy;
            best_net = net;
            best_tr = tr;
            best_params = network_config;
            best_params.learning_rate = learning_rate;
            best_params.max_epochs = max_epochs;
            best_training_time = training_time;
            
            logInfo('🏆 Nowy najlepszy wynik: %.2f%% (czas: %.2fs)', best_accuracy*100, best_training_time);
            
            % Sprawdzenie złotych parametrów
            if accuracy >= config.golden_accuracy && ~golden_found
                golden_found = true;
                optimization_results.golden_trial = trial;
                logSuccess('🌟 Znaleziono złote parametry (dokładność ≥ %.2f%%)!', config.golden_accuracy*100);
                
                % Jeśli znaleziono złote parametry, możemy przerwać wcześniej
                if isfield(config, 'early_stopping') && config.early_stopping
                    logInfo('🛑 Przerywam wcześniej - znaleziono złote parametry');
                    break;
                end
            end
        end
        
    catch e
        logWarning('⚠️ Próba %d nie powiodła się: %s', trial, e.message);
        optimization_results.trials(trial).error = e.message;
    end
end

% Zapisz wyniki optymalizacji
optimization_results.best_accuracy = best_accuracy;
optimization_results.best_params = best_params;
optimization_results.best_training_time = best_training_time;
optimization_results.golden_found = golden_found;
optimization_results.scenario = config.scenario;
optimization_results.num_completed_trials = trial;

% Dodaj macierz konfuzji do wyników (użyteczne dla compareNetworks)
try
    y_pred = best_net(X');
    [~, pred_idx] = max(y_pred, [], 1);
    [~, true_idx] = max(Y', [], 1);
    optimization_results.confusion_matrix = confusionmat(true_idx, pred_idx);
catch
    % W przypadku błędu, nie dodawaj macierzy konfuzji
end

% Podsumowanie wyników
logInfo('📊 Podsumowanie optymalizacji dla scenariusza: %s', config.scenario);
logInfo('   Najlepsza dokładność: %.2f%%', best_accuracy*100);
logInfo('   Typ sieci: %s', best_params.type);
logInfo('   Warstwy ukryte: %s', mat2str(best_params.hidden_layers));
logInfo('   Algorytm uczenia: %s (lr=%.5f)', best_params.training_algorithm, best_params.learning_rate);
logInfo('   Funkcja aktywacji: %s', best_params.activation_function);
logInfo('   Liczba epok: %d', best_params.max_epochs);
logInfo('   Czas treningu: %.2f sekund', best_training_time);
logInfo('   Złote parametry: %s', iif(golden_found, 'tak', 'nie'));

end

function result = iif(condition, true_value, false_value)
% Prosty odpowiednik operatora ?: z innych języków
if condition
    result = true_value;
else
    result = false_value;
end
end