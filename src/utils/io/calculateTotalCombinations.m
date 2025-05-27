function total = calculateTotalCombinations(config)
% =========================================================================
% OBLICZENIE CAŁKOWITEJ LICZBY KOMBINACJI
% =========================================================================

total = 1;

% Architektury
if isfield(config, 'network_architectures') && ~isempty(config.network_architectures)
    total = total * length(config.network_architectures);
end

% Warstwy ukryte
if isfield(config, 'hidden_layers_options') && ~isempty(config.hidden_layers_options)
    total = total * length(config.hidden_layers_options);
end

% Funkcje trenowania
if isfield(config, 'training_functions') && ~isempty(config.training_functions)
    total = total * length(config.training_functions);
end

% Funkcje aktywacji
if isfield(config, 'activation_functions') && ~isempty(config.activation_functions)
    total = total * length(config.activation_functions);
end

% Learning rates
if isfield(config, 'learning_rates') && ~isempty(config.learning_rates)
    total = total * length(config.learning_rates);
end

% Epoki
if isfield(config, 'epochs_options') && ~isempty(config.epochs_options)
    total = total * length(config.epochs_options);
end

% Performance goals
if isfield(config, 'performance_goals') && ~isempty(config.performance_goals)
    total = total * length(config.performance_goals);
end

logDebug('🧮 Obliczono total kombinacji: %d', total);

end