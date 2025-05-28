function params = sampleAdamHyperparameters(config)
% =========================================================================
% LOSOWANIE HIPERPARAMETRÓW DLA ADAM
% =========================================================================

params = struct();

% Learning rate
lr_idx = randi(length(config.learning_rates));
params.learning_rate = config.learning_rates(lr_idx);

% Architektura sieci
arch_idx = randi(length(config.hidden_layers_options));
params.hidden_layers = config.hidden_layers_options{arch_idx};

% Funkcja treningu
train_idx = randi(length(config.train_functions));
params.train_function = config.train_functions{train_idx};

% Funkcja aktywacji
act_idx = randi(length(config.activation_functions));
params.activation_function = config.activation_functions{act_idx};

% Liczba epok
epochs_idx = randi(length(config.epochs_range));
params.epochs = config.epochs_range(epochs_idx);

% Validation checks
val_idx = randi(length(config.validation_checks_range));
params.validation_checks = config.validation_checks_range(val_idx);

% Podział danych
train_idx = randi(length(config.train_ratios));
params.train_ratio = config.train_ratios(train_idx);

val_idx = randi(length(config.val_ratios));
params.val_ratio = config.val_ratios(val_idx);

test_idx = randi(length(config.test_ratios));
params.test_ratio = config.test_ratios(test_idx);

% Upewnienie się, że suma proporcji = 1.0
total = params.train_ratio + params.val_ratio + params.test_ratio;
if abs(total - 1.0) > 0.01
    % Normalizacja jeśli suma nie wynosi 1.0
    params.train_ratio = params.train_ratio / total;
    params.val_ratio = params.val_ratio / total;
    params.test_ratio = params.test_ratio / total;
end

end