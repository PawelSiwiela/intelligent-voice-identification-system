function config = gridSearchConfig()
% =========================================================================
% KONFIGURACJA GRID SEARCH - POPULARNE SKUTECZNE FUNKCJE
% =========================================================================

config = struct();

% =========================================================================
% ARCHITEKTURY
% =========================================================================
config.network_architectures = {
    'pattern',           % Klasyfikacja
    'feedforward',       % Podstawowy MLP
    };

% =========================================================================
% STRUKTURY SIECI - POPRAWIONE FORMATOWANIE
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
% FUNKCJE TRENOWANIA
% =========================================================================
config.training_functions = {
    'trainlm';
    'trainscg';
    'trainrp';
    'traingdx'
    };

config.activation_functions = {'tansig'};

% =========================================================================
% LEARNING RATES
% =========================================================================
config.learning_rates = [0.01, 0.05, 0.1];

% =========================================================================
% PARAMETRY TRENOWANIA
% =========================================================================
config.epochs_options = [3000];
config.performance_goals = [1e-6];

% =========================================================================
% LIMITY
% =========================================================================
config.max_combinations = 500;
config.max_training_time = 60;
config.timeout_per_config = 20;

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
config.create_plots = true;
config.verbose_logging = true;
config.results_dir = 'output/results';
config.networks_dir = 'output/networks';

% =========================================================================
% OBLICZENIE KOMBINACJI
% =========================================================================
total_combinations = length(config.network_architectures) * ...
    length(config.hidden_layers_options) * ...
    length(config.training_functions) * ...
    length(config.activation_functions) * ...
    length(config.learning_rates) * ...
    length(config.epochs_options) * ...
    length(config.performance_goals);

% Ogranicz do max_combinations
total_combinations = min(total_combinations, config.max_combinations);

logDebug('📋 FAST Grid Search - BEZ trainbr!');
logDebug('   🎯 Funkcje: trainlm, trainscg, trainrp, traingdx');
logDebug('   🧠 Kombinacji: %d', total_combinations);
logDebug('   ⏱️ Czas: ~20 minut (szybkie funkcje)');

end