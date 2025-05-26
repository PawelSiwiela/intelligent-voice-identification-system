function config = gridSearchConfig()
% =========================================================================
% KONFIGURACJA GRID SEARCH DLA OPTYMALIZACJI SIECI
% =========================================================================
% Centralna konfiguracja wszystkich parametrów grid search
% AUTOR: Paweł Siwiela, 2025
% =========================================================================

config = struct();

% =========================================================================
% ARCHITEKTURY SIECI
% =========================================================================
config.network_architectures = {'feedforward', 'cascade', 'pattern'};

% =========================================================================
% PARAMETRY STRUKTURALNE
% =========================================================================
config.hidden_layers_options = {
    [10],           % Single layer - small
    [15],           % Single layer - medium  
    [20],           % Single layer - large
    [10 5],         % Two layers - decreasing
    [15 8],         % Two layers - medium
    [20 10],        % Two layers - large
    [15 10 5]       % Three layers - pyramid
};

% =========================================================================
% FUNKCJE TRENOWANIA
% =========================================================================
config.training_functions = {
    'trainlm',      % Levenberg-Marquardt (fast, good for small datasets)
    'trainbr',      % Bayesian Regularization (prevents overfitting)
    'trainscg'      % Scaled Conjugate Gradient (memory efficient)
};

% =========================================================================
% FUNKCJE AKTYWACJI
% =========================================================================
config.activation_functions = {
    'tansig',       % Hyperbolic tangent sigmoid
    'logsig',       % Logarithmic sigmoid
    'purelin'       % Linear transfer function
};

% =========================================================================
% PARAMETRY UCZENIA
% =========================================================================
config.learning_rates = [0.001, 0.01, 0.05, 0.1];

% =========================================================================
% PARAMETRY TRENOWANIA
% =========================================================================
config.epochs_options = [500, 1000, 1500];
config.performance_goals = [1e-6, 1e-7, 1e-8];

% =========================================================================
% CROSS-VALIDATION
% =========================================================================
config.cv_folds = 5;                    % Liczba folds dla cross-validation

% =========================================================================
% LIMITY BEZPIECZEŃSTWA
% =========================================================================
config.max_combinations = 200;          % Maksymalna liczba kombinacji
config.max_training_time = 60;          % Maksymalny czas trenowania [s]
config.timeout_per_config = 10;         % Timeout dla jednej konfiguracji [s]

% =========================================================================
% METRYKI I EWALUACJA
% =========================================================================
config.primary_metric = 'accuracy';     % Główna metryka optymalizacji
config.secondary_metrics = {'precision', 'recall', 'f1_score'};

% =========================================================================
% RAPORTOWANIE
% =========================================================================
config.save_results = true;             % Czy zapisywać wyniki
config.create_plots = true;             % Czy tworzyć wykresy
config.verbose_logging = true;          % Szczegółowe logowanie

% =========================================================================
% ŚCIEŻKI ZAPISU
% =========================================================================
config.results_dir = 'output/results';
config.networks_dir = 'output/networks';

logDebug('📋 Załadowano konfigurację Grid Search');
logDebug('   🏗️ Architektury: %d', length(config.network_architectures));
logDebug('   🧠 Warstwy ukryte: %d opcji', length(config.hidden_layers_options));
logDebug('   ⚙️ Funkcje trenowania: %d', length(config.training_functions));
logDebug('   📈 Learning rates: %d', length(config.learning_rates));
logDebug('   🎯 Maksimum kombinacji: %d', config.max_combinations);

end