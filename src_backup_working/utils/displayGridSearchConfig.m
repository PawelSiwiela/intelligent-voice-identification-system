function displayGridSearchConfig(config, X, Y, labels)
% =========================================================================
% WYŚWIETLENIE KONFIGURACJI GRID SEARCH
% =========================================================================

logInfo('📊 Konfiguracja Grid Search:');

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

% CV i limity
if isfield(config, 'cv_folds')
    logInfo('   🔄 CV folds: %d', config.cv_folds);
end

if isfield(config, 'max_combinations')
    logInfo('   🎯 Max kombinacji: %d', config.max_combinations);
end

% Informacje o danych
if nargin >= 4
    [num_samples, num_features] = size(X);
    num_classes = length(labels);
    logInfo('');
    logInfo('📈 Dane wejściowe: %d próbek × %d cech → %d klas', ...
        num_samples, num_features, num_classes);
end

end