function param_ranges = defineParameterRanges(config)
% DEFINEPARAMETERRANGES Definiuje zakresy parametrów dla algorytmu genetycznego
%
% Składnia:
%   param_ranges = defineParameterRanges(config)
%
% Argumenty:
%   config - struktura konfiguracyjna
%
% Zwraca:
%   param_ranges - struktura z definicjami zakresów parametrów

% Inicjalizacja struktury z domyślnymi wartościami
param_ranges = struct();

% NAJPIERW USTAW DOMYŚLNE WARTOŚCI DLA WSZYSTKICH TABLIC
param_ranges.network_types = {'patternnet', 'feedforwardnet'};
param_ranges.hidden_layers = {[10], [15], [20]}; % Domyślne warstwy ukryte
param_ranges.training_algs = {'trainlm', 'trainscg'};
param_ranges.activation_functions = {'logsig', 'tansig'};
param_ranges.learning_rates = [0.01, 0.015, 0.02];
param_ranges.epochs_range = [200, 300];

% Sprawdzenie czy jest pole network_types w konfiguracji
if isfield(config, 'network_types') && ~isempty(config.network_types)
    param_ranges.network_types = config.network_types;
end

% Konfiguracja warstw ukrytych w zależności od scenariusza
if isfield(config, 'scenario')
    switch config.scenario
        case 'vowels'
            % Scenariusz tylko samogłoski - prostszy problem
            param_ranges.hidden_layers = {[8], [10], [12], [8 4], [10 5], [12 6]};
            param_ranges.training_algs = {'trainscg', 'traingdx', 'trainlm'};
            param_ranges.activation_functions = {'logsig', 'tansig'};
            param_ranges.epochs_range = [100, 150, 200];
            param_ranges.learning_rates = [0.01, 0.015, 0.02, 0.025, 0.03];
            
        case 'commands'
            % Scenariusz tylko komendy złożone - średnio złożony problem
            param_ranges.hidden_layers = {[10], [15], [20], [10 5], [15 8], [20 10]};
            param_ranges.training_algs = {'trainscg', 'trainlm', 'traingdx', 'trainbfg'};
            param_ranges.activation_functions = {'logsig', 'tansig'};
            param_ranges.epochs_range = [150, 200, 300];
            param_ranges.learning_rates = [0.01, 0.015, 0.02, 0.025, 0.03];
            
        case 'all'
            % Scenariusz wszystkie dane - najbardziej złożony problem
            param_ranges.hidden_layers = {[10], [12], [15], [10 5], [12 6], [15 8], [12 6 3]};
            param_ranges.training_algs = {'trainbr', 'trainlm', 'trainscg'};
            param_ranges.activation_functions = {'logsig', 'tansig'};
            param_ranges.epochs_range = [200, 300, 500];
            param_ranges.learning_rates = [0.005, 0.01, 0.015, 0.02, 0.025, 0.03];
    end
end

% Sprawdź, czy wszystkie tablice są niepuste
% Jeśli któraś jest pusta, użyj domyślnych wartości
if isempty(param_ranges.hidden_layers)
    param_ranges.hidden_layers = {[10], [15], [20]};
    disp('Ostrzeżenie: Pusta tablica hidden_layers - używam wartości domyślnych');
end

if isempty(param_ranges.training_algs)
    param_ranges.training_algs = {'trainlm', 'trainscg'};
    disp('Ostrzeżenie: Pusta tablica training_algs - używam wartości domyślnych');
end

if isempty(param_ranges.activation_functions)
    param_ranges.activation_functions = {'logsig', 'tansig'};
    disp('Ostrzeżenie: Pusta tablica activation_functions - używam wartości domyślnych');
end

if isempty(param_ranges.learning_rates)
    param_ranges.learning_rates = [0.01, 0.015, 0.02];
    disp('Ostrzeżenie: Pusta tablica learning_rates - używam wartości domyślnych');
end

if isempty(param_ranges.epochs_range)
    param_ranges.epochs_range = [200, 300];
    disp('Ostrzeżenie: Pusta tablica epochs_range - używam wartości domyślnych');
end

% Liczba parametrów do zakodowania w genotypie
param_ranges.num_genes = 5;  % typ sieci, warstwy ukryte, alg. uczenia, f. aktywacji, lr
if isfield(param_ranges, 'epochs_range') && ~isempty(param_ranges.epochs_range)
    param_ranges.num_genes = param_ranges.num_genes + 1;  % dodaj epoki jeśli są
end

% DODATKOWE SPRAWDZENIE DŁUGOŚCI TABLIC
% Wyświetl diagnostykę, aby zidentyfikować problem
disp(['INFO: Długość param_ranges.network_types: ', num2str(length(param_ranges.network_types))]);
disp(['INFO: Długość param_ranges.hidden_layers: ', num2str(length(param_ranges.hidden_layers))]);
disp(['INFO: Długość param_ranges.training_algs: ', num2str(length(param_ranges.training_algs))]);
disp(['INFO: Długość param_ranges.activation_functions: ', num2str(length(param_ranges.activation_functions))]);
disp(['INFO: Długość param_ranges.learning_rates: ', num2str(length(param_ranges.learning_rates))]);

end