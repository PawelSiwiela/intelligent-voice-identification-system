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
%     .training_algorithm - algorytm uczenia ('trainscg', 'trainlm', ...)
%     .activation_function - funkcja aktywacji (domyślnie 'logsig')
%
% Zwraca:
%   net - utworzona sieć neuronowa

% Domyślne parametry
if nargin < 3
    config = struct();
end

if ~isfield(config, 'type')
    config.type = 'patternnet';
end

if ~isfield(config, 'hidden_layers')
    config.hidden_layers = [20 10];
end

if ~isfield(config, 'training_algorithm')
    config.training_algorithm = 'trainlm';
end

if ~isfield(config, 'activation_function')
    config.activation_function = 'logsig';
end

% Utworzenie sieci danego typu
switch config.type
    case 'patternnet'
        net = patternnet(config.hidden_layers, config.training_algorithm);
    case 'feedforwardnet'
        net = feedforwardnet(config.hidden_layers, config.training_algorithm);
    otherwise
        logWarning('⚠️ Nieznany typ sieci: %s. Używam patternnet.', config.type);
        net = patternnet(config.hidden_layers, config.training_algorithm);
end

% Funkcje aktywacji dla warstw ukrytych
for i = 1:length(config.hidden_layers)
    net.layers{i}.transferFcn = config.activation_function;
end

% Podział danych według specyfikacji 7:3
net.divideParam.trainRatio = 0.7;    % 70% danych do treningu
net.divideParam.valRatio = 0.0;      % nie używamy walidacji przy podziale 7:3
net.divideParam.testRatio = 0.3;     % 30% danych do testu

logInfo('🧠 Utworzono sieć %s z warstwami ukrytymi %s i algorytmem %s', ...
    config.type, mat2str(config.hidden_layers), config.training_algorithm);

end