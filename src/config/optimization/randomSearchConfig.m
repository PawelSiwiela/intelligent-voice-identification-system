% Nowy plik: src/config/optimization/randomSearchConfig.m
function config = randomSearchConfig()
% =========================================================================
% KONFIGURACJA RANDOM SEARCH
% =========================================================================

% Podstawowe parametry jak w Grid Search
config = gridSearchConfig(); % Dziedzicz z Grid Search

% Specyficzne dla Random Search
config.method = 'random_search';
config.max_iterations = 100;           % Liczba losowych prób
config.random_seed = 42;               % Seed dla powtarzalności
config.early_stopping = true;          % Zatrzymaj jeśli brak poprawy
config.patience = 20;                  % Ile iteracji bez poprawy
config.min_improvement = 0.001;        % Minimalna poprawa accuracy

% Rozkłady probabilistyczne dla parametrów
config.sampling_strategy = struct();
config.sampling_strategy.hidden_layers = 'uniform';  % uniform, normal, log-uniform
config.sampling_strategy.learning_rate = 'log-uniform';
config.sampling_strategy.architecture = 'uniform';

logDebug('📋 Random Search Config');
logDebug('   🎲 Max iteracji: %d', config.max_iterations);
logDebug('   🔄 Early stopping: %s', yesno(config.early_stopping));

end