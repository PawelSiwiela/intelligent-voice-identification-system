function net = createNeuralNetwork(architecture, hidden_layers, train_func, activation_func, learning_rate, epochs, goal)
% =========================================================================
% TWORZENIE SIECI NEURONOWEJ Z OKREŚLONYMI PARAMETRAMI
% =========================================================================

try
    % Wybór typu sieci na podstawie architektury
    switch lower(architecture)
        case 'pattern'
            % Pattern Recognition Network
            net = patternnet(hidden_layers, train_func);
            
        case 'feedforward'
            % Feedforward Network
            net = feedforwardnet(hidden_layers, train_func);
            
        case 'fit'
            % Function Fitting Network
            net = fitnet(hidden_layers, train_func);
            
        otherwise
            % Domyślnie pattern recognition
            net = patternnet(hidden_layers, train_func);
    end
    
    % =====================================================================
    % KONFIGURACJA PARAMETRÓW SIECI
    % =====================================================================
    
    % Funkcja trenowania
    net.trainFcn = train_func;
    
    % Funkcje aktywacji dla warstw ukrytych
    for i = 1:length(hidden_layers)
        net.layers{i}.transferFcn = activation_func;
    end
    
    % Learning rate
    if strcmp(train_func, 'trainbr')
        % Bayesian Regularization - inne parametry
        net.trainParam.epochs = epochs;
        net.trainParam.goal = goal;
        net.trainParam.mu = learning_rate / 100;  % Dostosowanie dla BR
    elseif strcmp(train_func, 'trainlm')
        % Levenberg-Marquardt
        net.trainParam.epochs = epochs;
        net.trainParam.goal = goal;
        net.trainParam.lr = learning_rate;
        net.trainParam.mu = 0.001;
    else
        % Standardowe parametry dla innych algorytmów
        net.trainParam.epochs = epochs;
        net.trainParam.goal = goal;
        net.trainParam.lr = learning_rate;
    end
    
    % =====================================================================
    % DODATKOWE USTAWIENIA TRENOWANIA
    % =====================================================================
    
    % Podział danych (nie używane przy CV, ale dla bezpieczeństwa)
    net.divideParam.trainRatio = 0.8;
    net.divideParam.valRatio = 0.1;
    net.divideParam.testRatio = 0.1;
    
    % Ustawienia wydajności
    net.trainParam.showWindow = false;      % Wyłącz okno trenowania
    net.trainParam.showCommandLine = false; % Wyłącz komunikaty w konsoli
    net.trainParam.show = 25;               % Pokazuj co 25 epok
    
    % Timeouts
    net.trainParam.time = inf;              % Brak limitu czasowego
    net.trainParam.min_grad = 1e-7;        % Minimalne gradienty
    
    % Early stopping dla niektórych algorytmów
    if ~strcmp(train_func, 'trainbr')
        net.trainParam.max_fail = 6;       % Maksymalne nieudane validacje
    end
    
    logDebug('🧠 Utworzono sieć %s: warstwy=%s, train=%s', ...
        architecture, mat2str(hidden_layers), train_func);
    logDebug('⚙️ Ustawiono funkcję aktywacji: %s', activation_func);
    logDebug('📈 Ustawiono learning rate: %.3f', learning_rate);
    
catch ME
    logError('❌ Błąd tworzenia sieci: %s', ME.message);
    % Zwróć prostą sieć jako fallback
    net = patternnet(10, 'trainbr');
    rethrow(ME);
end

end