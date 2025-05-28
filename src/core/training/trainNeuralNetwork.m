function [net, accuracy] = trainNeuralNetwork(X, Y, params, show_window)
% TRAINNEURALNETWORK Uniwersalna funkcja trenująca sieć neuronową
%
% PARAMETRY:
%   X           - Dane wejściowe [samples x features]
%   Y           - Dane wyjściowe (etykiety) [samples x classes]
%   params      - Struktura parametrów sieci (hidden_layers, learning_rate, itp.)
%   show_window - (opcjonalny) Czy pokazać okno trenowania (domyślnie: false)

% ===== PARAMETRY DOMYŚLNE =====
if nargin < 4
    show_window = false;
end

% Tworzenie sieci - DOKŁADNIE JAK W TRAINWITHRANDOMPARAMS
net = patternnet(params.hidden_layers, params.train_function);

% ===== PARAMETRY SIECI =====
logInfo('🧠 Tworzenie sieci neuronowej...');
logInfo('   🔸 Architektura: %s', mat2str(params.hidden_layers));
logInfo('   🔸 Funkcja treningu: %s', params.train_function);
logInfo('   🔸 Learning rate: %.4f', params.learning_rate);
logInfo('   🔸 Liczba epok: %d', params.epochs);

% Ustawienia parametrów wyświetlania - DOKŁADNIE JAK W TRAINWITHRANDOMPARAMS
net.trainParam.showWindow = show_window;        % ⚠️ NAJWAŻNIEJSZE!
net.trainParam.showCommandLine = show_window;   % Wyłącz output w command line
if show_window
    net.trainParam.show = 25;
else
    net.trainParam.show = NaN;  % Ważne - dokładna wartość
end

% Funkcje wizualizacji - DOKŁADNIE JAK W TRAINWITHRANDOMPARAMS
if show_window
    % Używaj TYLKO tych, które są w trainFinalNetwork
    net.plotFcns = {'plotperform', 'plottrainstate'};
else
    net.plotFcns = {};  % Całkowite usunięcie wszystkich funkcji plotów
end

% Parametry treningu - DOKŁADNIE JAK W TRAINWITHRANDOMPARAMS
net.trainParam.lr = params.learning_rate;  % To samo ustawienie co w trainWithRandomParams
net.trainParam.epochs = params.epochs;

if isfield(params, 'performance_goal')
    net.trainParam.goal = params.performance_goal;
end

if isfield(params, 'validation_checks')
    net.trainParam.max_fail = params.validation_checks;
end

% ===== TRENOWANIE Z KONTROLĄ CZASU =====
training_start = tic;
max_training_time = 45; % 45 sekund domyślny timeout

% Sprawdź czy params ma timeout (jeśli będzie przekazywany z config)
if isfield(params, 'timeout_per_iteration')
    max_training_time = params.timeout_per_iteration;
end

try
    % Trenowanie sieci - DOKŁADNIE JAK W TRAINWITHRANDOMPARAMS
    net = train(net, X', Y');
    
    training_time = toc(training_start);
    
    % Sprawdzenie czy trenowanie nie trwało za długo
    if training_time > max_training_time * 1.2  % 20% tolerancja
        logWarning('⚠️ Trenowanie trwało długo: %.1fs (limit: %ds)', ...
            training_time, max_training_time);
    end
    
catch ME
    training_time = toc(training_start);
    
    % Sprawdź czy to może być timeout
    if training_time > max_training_time
        logWarning('⏰ Możliwy timeout po %.1fs - parametry: [%s], %s', ...
            training_time, mat2str(params.hidden_layers), params.train_function);
    end
    
    % Re-throw error
    rethrow(ME);
end

% Obliczenie accuracy - DOKŁADNIE JAK W TRAINWITHRANDOMPARAMS
outputs = net(X');
accuracy = sum(vec2ind(outputs) == vec2ind(Y')) / size(Y, 1);

end