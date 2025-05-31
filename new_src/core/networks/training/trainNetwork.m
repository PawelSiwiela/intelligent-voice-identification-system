function [net, tr, training_results] = trainNetwork(net, X, Y, config)
% TRAINNETWORK Trenuje sieć neuronową do rozpoznawania głosu
%
% Składnia:
%   [net, tr, training_results] = trainNetwork(net, X, Y, config)
%
% Argumenty:
%   net - sieć neuronowa do trenowania
%   X - macierz cech [próbki × cechy]
%   Y - macierz etykiet [próbki × kategorie] (one-hot encoding)
%   config - struktura konfiguracyjna z polami:
%     .learning_rate - współczynnik uczenia (domyślnie 0.01)
%     .max_epochs - maksymalna liczba epok (domyślnie 200)
%     .validation_checks - liczba sprawdzeń walidacyjnych (domyślnie 15)
%     .show_progress - czy pokazywać okno postępu (domyślnie true)
%
% Zwraca:
%   net - wytrenowana sieć neuronowa
%   tr - dane z procesu treningu
%   training_results - struktura z wynikami treningu

% Domyślne parametry
if nargin < 4
    config = struct();
end

if ~isfield(config, 'learning_rate')
    config.learning_rate = 0.01;
end

if ~isfield(config, 'max_epochs')
    config.max_epochs = 200;
end

if ~isfield(config, 'validation_checks')
    config.validation_checks = 15;
end

if ~isfield(config, 'show_progress')
    config.show_progress = true;
end

if ~isfield(config, 'show_command_line')
    config.show_command_line = false;  % Domyślnie wyłączone
end

% Transpozycja danych do formatu wymaganego przez Neural Network Toolbox
X_net = X';
Y_net = Y';

% Konfiguracja parametrów trenowania
net.trainParam.lr = config.learning_rate;          % Współczynnik uczenia
net.trainParam.epochs = config.max_epochs;         % Maksymalna liczba epok
net.trainParam.max_fail = config.validation_checks; % Liczba sprawdzeń walidacyjnych
net.trainParam.showWindow = config.show_progress;   % Pokazywanie okna postępu
net.trainParam.showCommandLine = ~config.show_progress; % Alternatywnie - linia poleceń

% Trenowanie sieci
logInfo('🔄 Rozpoczynam trenowanie sieci...');
tic;
[net, tr] = train(net, X_net, Y_net);
training_time = toc;

% Ewaluacja sieci
y_pred = net(X_net);
[~, pred_idx] = max(y_pred, [], 1);
[~, true_idx] = max(Y_net, [], 1);
accuracy = sum(pred_idx == true_idx) / length(true_idx);

% Obliczenie macierzy konfuzji
confusion_matrix = confusionmat(true_idx, pred_idx);

% Zwrócenie wyników
training_results = struct(...
    'accuracy', accuracy, ...
    'confusion_matrix', confusion_matrix, ...
    'best_epoch', tr.best_epoch, ...
    'training_time', training_time);

logInfo('✅ Trenowanie zakończone. Dokładność: %.2f%%, czas: %.2fs', accuracy*100, training_time);

end