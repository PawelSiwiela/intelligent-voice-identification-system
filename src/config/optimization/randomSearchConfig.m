% Nowy plik: src/config/optimization/randomSearchConfig.m
function config = randomSearchConfig()
% =========================================================================
% RANDOM SEARCH CONFIG - MINIMALNA WERSJA
% =========================================================================

config = struct();
config.method = 'random_search';

% ===== CORE PARAMETERS =====
config.max_iterations = 120;

% Hiperparametry do losowego próbkowania
config.learning_rates = [
    0.001, 0.002, 0.003, 0.005, 0.008, ...
    0.01, 0.012, 0.015, 0.02, 0.025, ...
    0.03, 0.04, 0.05, 0.06, 0.07, ...
    0.08, 0.09, 0.1, 0.12, 0.15
    ];

% Architektury sieci - szeroki zakres
config.hidden_layers_options = {
    [12], [13], [14], [15], [16], [17], [18], ...
    [22], [23], [24], [25], [26], [27], [28], ...
    [32], [33], [34], [35], [36], [37], [38], ...
    [40], [41], [42], [43], [44], [45], [46], ...
    };

% Funkcje trenowania - wszystkie równoprawne
config.training_functions = {
    'trainbr',    % Bayesian Regularization
    'trainlm',    % Levenberg-Marquardt
    'trainscg',   % Scaled Conjugate Gradient
    };

% Funkcje aktywacji - wszystkie równoprawne
config.activation_functions = {
    'logsig',     % Logistic Sigmoid
    %'tansig',     % Hyperbolic Tangent Sigmoid
    };

% Parametry trenowania - losowy zakres
config.epochs_range = [100, 150, 200];
config.validation_checks_range = [10, 15];

% Podział danych
config.train_ratios = [0.75, 0.8];
config.val_ratios = [0.15, 0.2];
config.test_ratios = [0.05, 0.1];

% =========================================================================
% POLA KOMPATYBILNOŚCI Z SYSTEMEM
% =========================================================================
config.network_architectures = {'pattern'};
config.use_cross_validation = false;
config.cv_folds = 1;
config.use_simple_split = true;
config.multiple_runs_per_config = 1;
config.take_best_of_runs = true;
config.average_results = false;
config.max_combinations = config.max_iterations;
config.max_training_time = 60;
config.timeout_per_config = 45;

% Główne ratio (dla kompatybilności)
config.train_ratio = 0.8;
config.test_ratio = 0.2;

% Zapisywanie wyników
config.save_results = true;
config.create_plots = false;
config.verbose_logging = true;
config.results_dir = 'output/results';
config.networks_dir = 'output/networks';
config.primary_metric = 'accuracy';
config.secondary_metrics = {'precision', 'recall', 'f1_score'};

% Random search specific
config.random_seed = randi(10000);  % Losowy seed za każdym razem
config.early_stopping = true;
config.patience = 30;  % Mniejsza cierpliwość dla random search

% ===== TIMEOUT PARAMETERS =====
config.timeout_per_iteration = 45;   % 45 sekund na jeden zestaw parametrów
config.max_total_time = 3600;        % 1 godzina maksymalny czas całego search
config.timeout_action = 'skip';      % 'skip' lub 'abort' - co robić przy timeout
config.show_timeout_warnings = true; % Pokazuj ostrzeżenia o timeout

% =========================================================================
% ALIASY DLA KOMPATYBILNOŚCI Z sampleRandomParameters.m
% =========================================================================
config.epochs_options = config.epochs_range;
config.validation_checks_options = config.validation_checks_range;
config.performance_goals = [1e-7, 1e-6, 1e-5];

% =========================================================================
% USTAWIENIA TRENOWANIA - WYŁĄCZENIE PLOTÓW
% =========================================================================
config.show_plots = false;        % NIE pokazuj plotów
config.show_window = false;       % NIE pokazuj okna treningu
config.show_command_line = false; % NIE pokazuj w command line
config.plot_interval = NaN;       % Wyłącz plotting
config.verbose = false;           % Cichy tryb

% Ustawienia dla patternnet
config.train_show_window = false; % Główne ustawienie!
config.train_show_command_line = false;

% =========================================================================
% OBLICZENIE STATYSTYK
% =========================================================================
total_combinations_possible = length(config.learning_rates) * ...
    length(config.hidden_layers_options) * ...
    length(config.training_functions) * ...
    length(config.activation_functions) * ...
    length(config.epochs_range) * ...
    length(config.validation_checks_range);

total_tests = config.max_iterations;
estimated_time_minutes = total_tests * 0.75;
estimated_time_hours = estimated_time_minutes / 60;

% Szansa na trafienie najlepszej kombinacji
hit_probability = config.max_iterations / total_combinations_possible * 100;

% =========================================================================
% WYŚWIETLENIE KONFIGURACJI
% =========================================================================
logDebug('🎲 PURE Random Search - Równomierne próbkowanie');
logDebug('   🎯 Możliwych kombinacji: %d', total_combinations_possible);
logDebug('   🧪 Testów do wykonania: %d', total_tests);
logDebug('   📊 Pokrycie przestrzeni: %.6f%%', hit_probability);
logDebug('   📈 Learning rates: %d opcji [%.3f - %.3f]', ...
    length(config.learning_rates), min(config.learning_rates), max(config.learning_rates));
logDebug('   🧠 Architektury: %d opcji (single + multi layer)', length(config.hidden_layers_options));
logDebug('   ⚙️ Funkcje treningu: %d opcji (równoprawne)', length(config.training_functions));
logDebug('   🔧 Funkcje aktywacji: %d opcji (równoprawne)', length(config.activation_functions));
logDebug('   ⏱️ Szacowany czas: %.1f minut (%.1f godzin)', estimated_time_minutes, estimated_time_hours);
logDebug('   🎯 CEL: Znaleźć ukryte kombinacje (może > 95.9%%)!');

end