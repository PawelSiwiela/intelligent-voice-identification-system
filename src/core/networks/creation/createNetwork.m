function [net] = createNetwork(input_size, output_size, config)
% CREATENETWORK Tworzy sieć neuronową dla problemu rozpoznawania głosu
%
% Składnia:
%   [net] = createNetwork(input_size, output_size, config)
%
% Argumenty:
%   input_size - liczba wejść (cech)
%   output_size - liczba wyjść (kategorii)
%   config - struktura konfiguracyjna z polami:
%     .type - typ sieci ('patternnet', 'feedforwardnet')
%     .hidden_layers - liczba neuronów w warstwach ukrytych [n1, n2, ...]
%     .training_algorithm - algorytm uczenia
%     .activation_function - funkcja aktywacji
%
% Zwraca:
%   net - utworzona sieć neuronowa

% Inicjalizacja konfiguracji, jeśli nie podano
if nargin < 3
    config = struct();
end

% Określenie wartości domyślnych dla brakujących parametrów
if ~isfield(config, 'type') || isempty(config.type)
    config.type = 'patternnet';
end

if ~isfield(config, 'hidden_layers') || isempty(config.hidden_layers)
    config.hidden_layers = [10];
end

if ~isfield(config, 'training_algorithm') || isempty(config.training_algorithm)
    config.training_algorithm = 'trainlm';
end

% Upewnij się, że hidden_layers jest wektorem
if isscalar(config.hidden_layers)
    config.hidden_layers = [config.hidden_layers];
end

% Utworzenie sieci danego typu
switch config.type
    case 'patternnet'
        net = patternnet(config.hidden_layers, config.training_algorithm);
        logInfo('🧠 Utworzono sieć patternnet z warstwami ukrytymi %s i algorytmem %s', ...
            mat2str(config.hidden_layers), config.training_algorithm);
    case 'feedforwardnet'
        net = feedforwardnet(config.hidden_layers, config.training_algorithm);
        logInfo('🧠 Utworzono sieć feedforwardnet z warstwami ukrytymi %s i algorytmem %s', ...
            mat2str(config.hidden_layers), config.training_algorithm);
    otherwise
        logWarning('⚠️ Nieznany typ sieci: %s. Używam patternnet.', config.type);
        net = patternnet(config.hidden_layers, config.training_algorithm);
end

% Funkcje aktywacji dla warstw ukrytych
if isfield(config, 'activation_function') && ~isempty(config.activation_function)
    for i = 1:length(config.hidden_layers)
        net.layers{i}.transferFcn = config.activation_function;
    end
end

% Podział danych według specyfikacji 60:20:20
net.divideParam.trainRatio = 0.6;
net.divideParam.valRatio = 0.2;
net.divideParam.testRatio = 0.2;

% Ustawienia wyświetlania
net.trainParam.showWindow = false;
net.trainParam.showCommandLine = true;

% Learning rate
if isfield(config, 'learning_rate') && ~isempty(config.learning_rate)
    net.trainParam.lr = config.learning_rate;
end

% Maksymalna liczba epok
if isfield(config, 'max_epochs') && ~isempty(config.max_epochs)
    net.trainParam.epochs = config.max_epochs;
end

% Dodatkowe parametry dla specyficznych algorytmów
if isfield(config, 'min_grad')
    net.trainParam.min_grad = config.min_grad;
end
if isfield(config, 'max_fail')
    net.trainParam.max_fail = config.max_fail;
end
if isfield(config, 'mu')
    net.trainParam.mu = config.mu;
end
if isfield(config, 'mu_dec')
    net.trainParam.mu_dec = config.mu_dec;
end
if isfield(config, 'mu_inc')
    net.trainParam.mu_inc = config.mu_inc;
end
end