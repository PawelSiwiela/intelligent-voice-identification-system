% Nowy plik: src/config/optimization/randomSearchConfig.m
function config = randomSearchConfig()
% =========================================================================
% KONFIGURACJA RANDOM SEARCH - NIEZALEŻNA OD GRID SEARCH
% =========================================================================

config = struct();

% =========================================================================
% METODA
% =========================================================================
config.method = 'random_search';

% =========================================================================
% PARAMETRY RANDOM SEARCH
% =========================================================================
config.max_iterations = 100;           % Liczba losowych prób
config.random_seed = 42;               % Seed dla powtarzalności

% Early stopping
config.early_stopping = true;          % ✅ Włącz early stopping
config.patience = 60;                  % ✅ 60 iteracji (3x więcej niż było)
config.min_improvement = 0.005;        % Minimalna poprawa 0.5%

% =========================================================================
% ARCHITEKTURY SIECI
% =========================================================================
config.network_architectures = {
    'pattern',           % Klasyfikacja wzorców
    'feedforward'        % Podstawowy MLP
    };

% =========================================================================
% STRUKTURY SIECI - ZOPTYMALIZOWANE DLA RANDOM SEARCH
% =========================================================================
config.hidden_layers_options = {
    [25];
    [30];
    [28];
    [32];
    [20 15];
    [25 20];
    [18 15 12]
    };

% =========================================================================
% FUNKCJE TRENOWANIA - SZYBKIE I SKUTECZNE
% =========================================================================
config.training_functions = {
    'trainlm';          % Levenberg-Marquardt (najlepszy)
    'trainrp';          % Resilient Backprop (szybki)
    'trainscg';         % Scaled Conjugate Gradient
    'traingdx'          % Gradient Descent z momentum
    };

% =========================================================================
% FUNKCJE AKTYWACJI
% =========================================================================
config.activation_functions = {
    'tansig';           % Tangens hiperboliczny
    'logsig'            % ✅ Dodaj drugą opcję dla Random Search
    };

% =========================================================================
% LEARNING RATES - SZERSZY ZAKRES
% =========================================================================
config.learning_rates = [
    0.005,              % Bardzo niski
    0.01,               % Niski
    0.05,               % Średni
    0.1,                % Wysoki
    ];

% =========================================================================
% PARAMETRY TRENOWANIA
% =========================================================================
config.epochs_options = [
    1500,               % Szybkie trenowanie
    3000,               % Standardowe
    5000                % ✅ Długie (dla Random Search)
    ];

config.performance_goals = [
    1e-6                % Bardzo restrykcyjny
    ];

% =========================================================================
% STRATEGIA PRÓBKOWANIA
% =========================================================================
config.sampling_strategy = struct();
config.sampling_strategy.hidden_layers = 'uniform';     % Równomierne
config.sampling_strategy.learning_rate = 'log-uniform'; % Log-równomierne
config.sampling_strategy.architecture = 'weighted';     % Ważone (pattern > feedforward)

% Wagi dla architektur (pattern lepszy niż feedforward)
config.architecture_weights = [0.7, 0.3];  % 70% pattern, 30% feedforward

% =========================================================================
% LIMITY I TIMEOUTY
% =========================================================================
config.max_training_time = 120;        % 2 minuty na trenowanie
config.timeout_per_config = 30;        % 30 sekund timeout

% =========================================================================
% PODZIAŁ DANYCH
% =========================================================================
config.use_simple_split = true;
config.train_ratio = 0.8;
config.test_ratio = 0.2;

% =========================================================================
% METRYKI
% =========================================================================
config.primary_metric = 'accuracy';
config.secondary_metrics = {'precision', 'recall', 'f1_score'};

% =========================================================================
% RAPORTOWANIE
% =========================================================================
config.save_results = true;
config.create_plots = false;           % Szybsze bez plotów
config.verbose_logging = false;        % Mniej logowania dla szybkości
config.results_dir = 'output/results';
config.networks_dir = 'output/networks';

% =========================================================================
% STATYSTYKI KONFIGURACJI
% =========================================================================

% Obliczenie teoretycznej przestrzeni przeszukiwania
total_space = length(config.network_architectures) * ...
    length(config.hidden_layers_options) * ...
    length(config.training_functions) * ...
    length(config.activation_functions) * ...
    length(config.learning_rates) * ...
    length(config.epochs_options) * ...
    length(config.performance_goals);

% Procent przeszukiwanej przestrzeni
coverage_percent = (config.max_iterations / total_space) * 100;

logDebug('🎲 RANDOM SEARCH CONFIG - NIEZALEŻNY');
logDebug('   🏗️ Architektury: %d opcji', length(config.network_architectures));
logDebug('   🧠 Struktury sieci: %d opcji', length(config.hidden_layers_options));
logDebug('   ⚙️ Funkcje trenowania: %d opcji', length(config.training_functions));
logDebug('   📈 Learning rates: %d opcji', length(config.learning_rates));
logDebug('   🎯 Max iteracji: %d', config.max_iterations);
logDebug('   🛑 Early stopping: %s (patience: %d)', yesno(config.early_stopping), config.patience);
logDebug('   📊 Przestrzeń: %d kombinacji (%.1f%% coverage)', total_space, coverage_percent);
logDebug('   ⏱️ Szacowany czas: %.1f-%.1f minut', config.max_iterations*0.1, config.max_iterations*0.3);

end