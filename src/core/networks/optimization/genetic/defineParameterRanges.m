function param_ranges = defineParameterRanges(config)
% DEFINEPARAMETERRANGES Definiuje zakresy parametrów dla optymalizacji sieci
%
% Składnia:
%   param_ranges = defineParameterRanges(config)
%
% Argumenty:
%   config - struktura konfiguracyjna
%
% Zwraca:
%   param_ranges - struktura z zakresami parametrów

% Inicjalizacja pustej struktury
param_ranges = struct();

% Obsługa ograniczenia do określonego typu sieci
if isfield(config, 'network_types') && length(config.network_types) == 1
    % Zapisz ustalony typ sieci
    param_ranges.fixed_network_type = config.network_types{1};
    param_ranges.network_types = config.network_types;
else
    % Domyślne typy sieci - skupienie na patternnet (najlepszy)
    param_ranges.network_types = {'patternnet'};
end

% Zakresy parametrów zależne od scenariusza
switch config.scenario
    case 'vowels'
        % Konfiguracja dla samogłosek - prostszy problem
        param_ranges.hidden_layers = {
            [8], [10], [12], [15]
            };
        param_ranges.training_algs = {'trainscg', 'traingdx', 'trainlm'};
        param_ranges.activation_functions = {'logsig', 'tansig'};
        param_ranges.epochs_range = [100, 150, 200];
        param_ranges.learning_rates = [0.01, 0.015, 0.02, 0.025, 0.03];
        
    case 'commands'
        % Konfiguracja dla komend - średnio złożony problem
        param_ranges.hidden_layers = {
            [10], [12], [14], [16], [18], [20], [22], [24], [26], [28]
            };
        param_ranges.training_algs = {'trainbr', 'trainlm'};
        param_ranges.activation_functions = {'logsig', 'tansig'};
        param_ranges.epochs_range = [150, 250, 350, 450];
        param_ranges.learning_rates = [0.01, 0.012, 0.014, 0.016, 0.018, 0.02];
        
    case 'all'
        % ZOPTYMALIZOWANA KONFIGURACJA - skupiamy się na eksploatacji najlepszych znanych parametrów
        param_ranges.hidden_layers = {
            [19], [20], [21], [22], [23], [24], [25], [26], [27], [28]
            };
        param_ranges.training_algs = {'trainlm', 'trainbr'};
        param_ranges.activation_functions = {'tansig', 'logsig'};
        param_ranges.learning_rates = [0.01, 0.012, 0.014, 0.016, 0.018, 0.02];
        param_ranges.epochs_range = [300, 350, 400];
        
    otherwise
        % Domyślne wartości dla nieznanych scenariuszy
        warning('Nieznany scenariusz: %s. Używam domyślnych wartości.', config.scenario);
end

% Sprawdzenie kompletności konfiguracji i uzupełnienie brakujących parametrów
if ~isfield(param_ranges, 'hidden_layers') || isempty(param_ranges.hidden_layers)
    param_ranges.hidden_layers = {[10], [15], [20]};
end

if ~isfield(param_ranges, 'training_algs') || isempty(param_ranges.training_algs)
    param_ranges.training_algs = {'trainlm'};
end

if ~isfield(param_ranges, 'activation_functions') || isempty(param_ranges.activation_functions)
    param_ranges.activation_functions = {'tansig'};
end

if ~isfield(param_ranges, 'learning_rates') || isempty(param_ranges.learning_rates)
    param_ranges.learning_rates = [0.01, 0.015, 0.02];
end

if ~isfield(param_ranges, 'epochs_range') || isempty(param_ranges.epochs_range)
    param_ranges.epochs_range = [300, 350];
end

% Liczba parametrów do zakodowania w genotypie
param_ranges.num_genes = 6;  % typ sieci, warstwy ukryte, alg. uczenia, f. aktywacji, lr, epoki

end