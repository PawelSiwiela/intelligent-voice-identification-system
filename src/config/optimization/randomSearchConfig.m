% Nowy plik: src/config/optimization/randomSearchConfig.m
function config = randomSearchConfig()
% =========================================================================
% RANDOM SEARCH CONFIG - MINIMALNA WERSJA
% =========================================================================

config = struct();
config.method = 'random_search';

% ===== CORE PARAMETERS =====
config.max_iterations = 180;

config.learning_rates = [
    0.002, 0.003, 0.004, 0.005, ...  
    0.008, 0.01, 0.012, 0.015, ...   
    0.06, 0.07, 0.08, 0.09           
];

config.hidden_layers_options = {
    [12], [13], [14], [15], [16], [17], [18], ...  
    [22], [23], [24], [25], [26], [27], [28], ...  
    [32], [33], [34], [35], [36], [37], [38]       
};

config.training_functions = {'trainbr', 'trainlm', 'trainscg', 'traincgb'};
config.training_weights = [0.4, 0.35, 0.2, 0.05];

config.activation_functions = {'logsig', 'tansig'};
config.activation_weights = [0.8, 0.2];

config.epochs_range = [100, 150, 200];
config.validation_checks_range = [10, 15];

config.train_ratios = [0.75, 0.8];
config.val_ratios = [0.15, 0.2];
config.test_ratios = [0.05, 0.1];

% =========================================================================
% WYMAGANE POLA (dla kompatybilności z systemem)
% =========================================================================
config.save_results = true;
config.create_plots = false;  % Random search nie potrzebuje plotów
config.verbose_logging = true;
config.results_dir = 'output/results';
config.networks_dir = 'output/networks';
config.primary_metric = 'accuracy';
config.secondary_metrics = {'precision', 'recall', 'f1_score'};

% =========================================================================
% POLA KOMPATYBILNOŚCI Z GRID SEARCH - BRAKUJĄCE!
% =========================================================================
config.network_architectures = {'pattern'};  % WAŻNE - używane w randomSearchOptimizer!
config.use_simple_split = true;             % Prosty split train/test
config.multiple_runs_per_config = 1;        % ⚠️ BRAKUJE - używane w obliczeniach!
config.take_best_of_runs = true;           
config.average_results = false;
config.max_combinations = config.max_iterations;  % Alias dla kompatybilności
config.max_training_time = 60;              % 1 min per konfiguracja
config.timeout_per_config = 45;             % 45s timeout per test

% Data split ratios (skonsolidowane dla kompatybilności)
config.train_ratio = 0.8;   % Główny ratio - BRAKUJE!
config.test_ratio = 0.2;    % Główny ratio - BRAKUJE!

% =========================================================================
% OBLICZENIE STATYSTYK I SZACOWANIE CZASU
% =========================================================================
total_iterations = config.max_iterations;
total_tests = total_iterations * config.multiple_runs_per_config;
estimated_time_minutes = total_tests * 0.75; % ~45s per iteration
estimated_time_hours = estimated_time_minutes / 60;

% =========================================================================
% WYŚWIETLENIE KONFIGURACJI (identyczne z gridSearchConfig)
% =========================================================================
logDebug('🎲 Intelligent Random Search - TARGET 97.7%%!');
logDebug('   🧠 Architectures: %d opcji (skupione na najlepszych z ADAM)', length(config.hidden_layers_options));
logDebug('   ⚙️ Funkcje: trainbr (%.0f%%), trainlm (%.0f%%), trainscg (%.0f%%)', ...
    config.training_weights(1)*100, config.training_weights(2)*100, config.training_weights(3)*100);
logDebug('   📈 LR: %d opcji - FOCUS na 0.08/0.01 (97.7%% z ADAM)!', length(config.learning_rates));
logDebug('   🎯 Weighted sampling: INTELIGENTNY bias na najlepsze');
logDebug('   🔄 Iterations: %d (vs CV w gridzie)', config.max_iterations);
logDebug('   🧪 Testów: %d', total_tests);
logDebug('   ⏱️ Szacowany czas: %.1f minut (%.1f godzin)', estimated_time_minutes, estimated_time_hours);
logDebug('   🎯 CEL: POWTÓRZYĆ 97.7%% accuracy z "ADAM"!');

end