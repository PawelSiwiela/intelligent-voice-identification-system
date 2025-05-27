function displayRandomSearchConfig(config, X, Y, labels)
% =========================================================================
% WYŚWIETLENIE KONFIGURACJI RANDOM SEARCH
% =========================================================================

logInfo('📊 Konfiguracja Random Search:');

% Podstawowe parametry
logInfo('   🎲 Max iteracji: %d', config.max_iterations);

if isfield(config, 'random_seed')
    logInfo('   🔢 Random seed: %d', config.random_seed);
end

% Architektury
if isfield(config, 'network_architectures')
    arch_str = strjoin(config.network_architectures, ', ');
    logInfo('   🏗️ Architektury: %s', arch_str);
end

% Warstwy ukryte
if isfield(config, 'hidden_layers_options')
    logInfo('   🧠 Warstwy ukryte: %d opcji', length(config.hidden_layers_options));
end

% Funkcje trenowania
if isfield(config, 'training_functions')
    train_str = strjoin(config.training_functions, ', ');
    logInfo('   ⚙️ Funkcje trenowania: %s', train_str);
end

% Learning rates
if isfield(config, 'learning_rates')
    logInfo('   📈 Learning rates: %d opcji', length(config.learning_rates));
end

% Early stopping
if isfield(config, 'early_stopping') && config.early_stopping
    if isfield(config, 'patience')
        logInfo('   🛑 Early stopping: TAK (patience: %d)', config.patience);
    else
        logInfo('   🛑 Early stopping: TAK');
    end
else
    logInfo('   🛑 Early stopping: NIE');
end

% Informacje o danych
if nargin >= 4
    [num_samples, num_features] = size(X);
    num_classes = length(labels);
    logInfo('');
    logInfo('📈 Dane wejściowe: %d próbek × %d cech → %d klas', ...
        num_samples, num_features, num_classes);
end

% Szacowany czas
if isfield(config, 'max_iterations')
    estimated_time = config.max_iterations * 5; % 5 sekund na iterację
    logInfo('⏱️ Szacowany czas: ~%.1f minut', estimated_time/60);
end

end