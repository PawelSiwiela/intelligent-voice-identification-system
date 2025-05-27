function net = createNeuralNetwork(architecture, hidden_layers, train_func, activation_func, learning_rate, epochs, goal)
% =========================================================================
% TWORZENIE SIECI NEURONOWEJ - POPRAWIONA WERSJA
% =========================================================================

try
    switch lower(architecture)
        case 'feedforward'
            % =============================================
            % FEEDFORWARD NEURAL NETWORK
            % =============================================
            net = feedforwardnet(hidden_layers);
            
        case 'pattern'
            % =============================================
            % PATTERN RECOGNITION NEURAL NETWORK
            % =============================================
            net = patternnet(hidden_layers);
            
        otherwise
            error('Nieznana architektura: %s', architecture);
    end
    
    % =========================================================================
    % KONFIGURACJA FUNKCJI TRENOWANIA
    % =========================================================================
    net.trainFcn = train_func;  % trainlm, trainbr, etc.
    
    % =========================================================================
    % KONFIGURACJA PARAMETRÓW TRENOWANIA
    % =========================================================================
    net.trainParam.epochs = epochs;
    net.trainParam.goal = goal;
    net.trainParam.lr = learning_rate;
    net.trainParam.showWindow = false;  % Wyłącz okno trenowania
    net.trainParam.showCommandLine = false;  % Wyłącz output w command line
    
    % =========================================================================
    % KONFIGURACJA FUNKCJI AKTYWACJI (tylko dla feedforward)
    % =========================================================================
    if strcmpi(architecture, 'feedforward')
        for i = 1:length(net.layers)
            if i < length(net.layers)  % Warstwy ukryte
                net.layers{i}.transferFcn = activation_func;
            else  % Warstwa wyjściowa
                net.layers{i}.transferFcn = 'softmax';  % Dla klasyfikacji
            end
        end
    end
    
    logDebug('🧠 Utworzono sieć %s: warstwy=%s, train=%s', ...
        architecture, mat2str(hidden_layers), train_func);
    logDebug('⚙️ Ustawiono funkcję aktywacji: %s', activation_func);
    logDebug('📈 Ustawiono learning rate: %.3f', learning_rate);
    
catch ME
    logError('❌ Błąd tworzenia sieci: %s', ME.message);
    net = [];
end

end