% Nowy plik: src/config/optimization/randomSearchConfig.m
function config = randomSearchConfig()
% =========================================================================
% KONFIGURACJA RANDOM SEARCH - ULEPSZONA DLA WYŻSZEJ SKUTECZNOŚCI
% =========================================================================

config = struct();

% =========================================================================
% METODA
% =========================================================================
config.method = 'random_search';

% =========================================================================
% PARAMETRY RANDOM SEARCH - ZWIĘKSZONE
% =========================================================================
config.max_iterations = 200;           % Zwiększone z 100 na 200
config.random_seed = 42;               % Seed dla powtarzalności

% Early stopping - BARDZIEJ AGRESYWNE
config.early_stopping = true;
config.patience = 80;                  % Zwiększone z 60 na 80
config.min_improvement = 0.002;        % Zmniejszone z 0.005 na 0.002

% =========================================================================
% ARCHITEKTURY SIECI
% =========================================================================
config.network_architectures = {
    'pattern',           % 80% szans
    'feedforward'        % 20% szans
    };

% =========================================================================
% STRUKTURY SIECI - DODAJ WIĘKSZE SIECI
% =========================================================================
config.hidden_layers_options = {
    [35];              % Pojedyncze warstwy
    [40];
    [45];
    [50];
    [60];
    [25];
    [30];
    [32];
    [28];
    [30 25];           % Dwuwarstwowe
    [35 30];
    [40 35];
    [45 40];
    [50 45];
    [25 20];
    [20 15];
    [25 20 15];        % Trójwarstwowe
    [30 25 20];
    [35 30 25];
    [40 35 30];
    [18 15 12]
    };

% =========================================================================
% FUNKCJE TRENOWANIA - WIĘCEJ OPCJI
% =========================================================================
config.training_functions = {
    'trainlm';          % Levenberg-Marquardt (40% szans)
    'trainbr';          % Bayesian Regularization (30% szans)
    'trainscg';         % Scaled Conjugate Gradient (20% szans)
    'trainrp';          % Resilient Backprop (10% szans)
    };

% =========================================================================
% FUNKCJE AKTYWACJI - WIĘCEJ EKSPERYMENTÓW
% =========================================================================
config.activation_functions = {
    'tansig';           % 50% szans
    'logsig';           % 40% szans
    'purelin'           % 10% szans
    };

% =========================================================================
% LEARNING RATES - SZERSZY ZAKRES
% =========================================================================
config.learning_rates = [
    0.001,              % Bardzo niski
    0.003,
    0.005,
    0.01,
    0.02,
    0.05,
    0.1,
    0.15,
    0.2                 % Bardzo wysoki
    ];

% =========================================================================
% PARAMETRY TRENOWANIA
% =========================================================================
config.epochs_options = [
    1500,
    2000,
    3000,
    4000,
    5000                % Długie trenowanie
    ];

config.performance_goals = [
    1e-7,               % Bardzo restrykcyjny
    1e-6,
    1e-5
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

logDebug('🎲 RANDOM SEARCH CONFIG - ULEPSZONA DLA WYŻSZEJ SKUTECZNOŚCI');
logDebug('   🏗️ Architektury: %d opcji', length(config.network_architectures));
logDebug('   🧠 Struktury sieci: %d opcji', length(config.hidden_layers_options));
logDebug('   ⚙️ Funkcje trenowania: %d opcji', length(config.training_functions));
logDebug('   📈 Learning rates: %d opcji', length(config.learning_rates));
logDebug('   🎯 Max iteracji: %d', config.max_iterations);
logDebug('   🛑 Early stopping: %s (patience: %d)', yesno(config.early_stopping), config.patience);
logDebug('   📊 Przestrzeń: %d kombinacji (%.1f%% coverage)', total_space, coverage_percent);
logDebug('   ⏱️ Szacowany czas: %.1f-%.1f minut', config.max_iterations*0.1, config.max_iterations*0.3);

end