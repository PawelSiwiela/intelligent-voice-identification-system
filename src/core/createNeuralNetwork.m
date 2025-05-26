function net = createNeuralNetwork(architecture_type, hidden_layers, varargin)
% =========================================================================
% KREATOR RÓŻNYCH ARCHITEKTUR SIECI NEURONOWYCH
% =========================================================================
% Tworzy różne typy sieci neuronowych z konfigurowalnymi parametrami
% AUTOR: Paweł Siwiela, 2025
% =========================================================================

% Parse optional parameters
p = inputParser;
addParameter(p, 'training_function', 'trainlm', @ischar);
addParameter(p, 'activation_function', 'tansig', @ischar);
addParameter(p, 'learning_rate', 0.01, @isnumeric);
parse(p, varargin{:});

training_func = p.Results.training_function;
activation_func = p.Results.activation_function;
learning_rate = p.Results.learning_rate;

% Pomiar czasu tworzenia sieci
creation_start = tic;

% =========================================================================
% TWORZENIE RÓŻNYCH ARCHITEKTUR
% =========================================================================

switch lower(architecture_type)
    case 'feedforward'
        % Klasyczna sieć feedforward (sprzężenie w przód)
        net = feedforwardnet(hidden_layers, training_func);
        logDebug('🧠 Utworzono sieć feedforward: warstwy=[%s], train=%s', ...
            num2str(hidden_layers), training_func);
        
    case 'cascade'
        % Sieć kaskadowa (każda warstwa łączy się ze wszystkimi następnymi)
        net = cascadeforwardnet(hidden_layers, training_func);
        logDebug('🔗 Utworzono sieć kaskadową: warstwy=[%s], train=%s', ...
            num2str(hidden_layers), training_func);
        
    case 'pattern'
        % Sieć do rozpoznawania wzorców (pattern recognition)
        net = patternnet(hidden_layers, training_func);
        logDebug('🎯 Utworzono sieć wzorców: warstwy=[%s], train=%s', ...
            num2str(hidden_layers), training_func);
        
    case 'fit'
        % Sieć do aproksymacji funkcji
        net = fitnet(hidden_layers, training_func);
        logDebug('📈 Utworzono sieć aproksymacyjną: warstwy=[%s], train=%s', ...
            num2str(hidden_layers), training_func);
        
    case 'layrecnet'
        % Sieć rekurencyjna (dla sekwencji czasowych)
        net = layrecnet(1:2, hidden_layers, training_func);
        logDebug('🔄 Utworzono sieć rekurencyjną: warstwy=[%s], train=%s', ...
            num2str(hidden_layers), training_func);
        
    case 'narnet'
        % Nonlinear autoregressive network
        net = narnet(1:2, hidden_layers, training_func);
        logDebug('📊 Utworzono sieć NAR: warstwy=[%s], train=%s', ...
            num2str(hidden_layers), training_func);
        
    otherwise
        logError('❌ Nieznany typ architektury: %s. Dostępne: feedforward, cascade, pattern, fit, layrecnet, narnet', ...
            architecture_type);
end

% =========================================================================
% KONFIGURACJA SIECI
% =========================================================================

% Ustawienie funkcji aktywacji dla warstw ukrytych
if ~isempty(activation_func)
    for i = 1:length(net.layers)-1  % Bez zmiany ostatniej warstwy (output)
        if ~isempty(net.layers{i})
            net.layers{i}.transferFcn = activation_func;
        end
    end
    logDebug('⚙️ Ustawiono funkcję aktywacji: %s', activation_func);
end

% Ustawienie learning rate
if ~isempty(learning_rate)
    net.trainParam.lr = learning_rate;
    logDebug('📈 Ustawiono learning rate: %.3f', learning_rate);
end

% Podstawowe ustawienia trenowania
net.trainParam.showWindow = false;      % Bez okna trenowania
net.trainParam.showCommandLine = false; % Bez outputu do konsoli
net.divideFcn = '';                     % Wyłączenie automatycznego podziału danych

creation_time = toc(creation_start);
logDebug('⏱️ Czas tworzenia sieci: %.3f s', creation_time);

end