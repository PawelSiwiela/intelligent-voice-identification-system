function params = sampleRandomParameters(config)
% =========================================================================
% LOSOWE PRÓBKOWANIE PARAMETRÓW SIECI NEURONOWEJ
% =========================================================================

params = struct();

% Losowa architektura
arch_idx = randi(length(config.network_architectures));
params.architecture = config.network_architectures{arch_idx};

% Losowe warstwy ukryte
hidden_idx = randi(length(config.hidden_layers_options));
params.hidden_layers = config.hidden_layers_options{hidden_idx};

% Losowa funkcja trenowania
train_idx = randi(length(config.training_functions));
params.train_func = config.training_functions{train_idx};

% Losowa funkcja aktywacji
act_idx = randi(length(config.activation_functions));
params.activation_func = config.activation_functions{act_idx};

% Losowy learning rate
lr_idx = randi(length(config.learning_rates));
params.learning_rate = config.learning_rates(lr_idx);

% Losowe epoki
epoch_idx = randi(length(config.epochs_options));
params.epochs = config.epochs_options(epoch_idx);

% Losowy goal
goal_idx = randi(length(config.performance_goals));
params.goal = config.performance_goals(goal_idx);

logDebug('🎲 Wylosowano: %s [%s], %s, lr=%.3f', ...
    params.architecture, mat2str(params.hidden_layers), ...
    params.train_func, params.learning_rate);

end