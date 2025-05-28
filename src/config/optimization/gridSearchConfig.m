function config = gridSearchConfig()
% =========================================================================
% POWRÓT DO WYGRYWAJĄCEJ KONFIGURACJI + CV - TARGET 90.9%
% =========================================================================

config = struct();

% =========================================================================
% ARCHITEKTURY
% =========================================================================
config.network_architectures = {'pattern'};

% =========================================================================
% STRUKTURY SIECI - FOCUS NA NAJLEPSZYCH Z HISTORII
% =========================================================================
config.hidden_layers_options = {
    [10]; [12]; [15]; [18]; [20]; [22];     % DODANO [15] - dał 90.9%!
    [12 10]; [15 12]; [18 15]; [20 15];     % Dwuwarstwowe wokół najlepszych
    };

% =========================================================================
% FUNKCJE TRENOWANIA - TYLKO NAJLEPSZE
% =========================================================================
config.training_functions = {'trainbr'};    % TYLKO trainbr - sprawdzony

% =========================================================================
% FUNKCJE AKTYWACJI
% =========================================================================
config.activation_functions = {'logsig'};   % Tylko najlepszy

% =========================================================================
% LEARNING RATES - WOKÓŁ HISTORYCZNIE NAJLEPSZYCH
% =========================================================================
config.learning_rates = [
    0.040,              % Dobry w ostatnich testach
    0.045,              % DAŁ 90.9%! KLUCZOWY!
    0.050               % Backup
    ];

% =========================================================================
% PARAMETRY TRENOWANIA
% =========================================================================
config.epochs_options = [2000, 3000];       % Dwie opcje
config.performance_goals = [1e-7, 1e-6];    % Dwie opcje

% =========================================================================
% CROSS VALIDATION - WŁĄCZONE!
% =========================================================================
config.use_cross_validation = true;         % ✅ WŁĄCZ CV!
config.cv_folds = 5;                        % 5-fold CV
config.cv_stratified = true;                % Stratified dla równomierności
config.use_simple_split = false;            % ❌ Wyłącz prosty split

% =========================================================================
% MULTIPLE RUNS - DLA STABILNOŚCI
% =========================================================================
config.multiple_runs_per_config = 3;        % 3 uruchomienia per konfiguracja
config.take_best_of_runs = false;           % Użyj średniej z CV
config.average_results = true;

% =========================================================================
% LIMITY
% =========================================================================
config.max_combinations = 200;              % Więcej kombinacji
config.max_training_time = 300;             % 5 minut per konfiguracja
config.timeout_per_config = 90;

config.train_ratio = 0.8;
config.test_ratio = 0.2;

% =========================================================================
% WYMAGANE POLA (dla kompatybilności)
% =========================================================================
config.save_results = true;
config.create_plots = false;
config.verbose_logging = true;
config.results_dir = 'output/results';
config.networks_dir = 'output/networks';
config.primary_metric = 'accuracy';
config.secondary_metrics = {'precision', 'recall', 'f1_score'};

% =========================================================================
% OBLICZENIE KOMBINACJI I SZACOWANIE CZASU
% =========================================================================
total_combinations = length(config.hidden_layers_options) * ...
    length(config.training_functions) * ...
    length(config.activation_functions) * ...
    length(config.learning_rates) * ...
    length(config.epochs_options) * ...
    length(config.performance_goals);

% Z CV
total_tests = total_combinations * config.cv_folds * config.multiple_runs_per_config;
estimated_time_hours = total_tests * 45 / 3600; % 45s per test

logDebug('🎯 ENHANCED Grid Search - ODZYSKAĆ 90.9%%!');
logDebug('   🧠 Pattern [10,12,15,18,20,22] + dwuwarstwowe');
logDebug('   ⚙️ TYLKO trainbr + logsig (proven winners)');
logDebug('   📈 LR: [0.040, 0.045, 0.050] - FOCUS na 0.045!');
logDebug('   🔄 Cross-validation: %d-fold stratified', config.cv_folds);
logDebug('   🎲 Multiple runs: %d per config', config.multiple_runs_per_config);
logDebug('   🧪 Kombinacji: %d | Testów: %d', total_combinations, total_tests);
logDebug('   ⏱️ Szacowany czas: %.1f godzin', estimated_time_hours);
logDebug('   🎯 CEL: STABILNE 90%%+ wyniki z CV!');

end