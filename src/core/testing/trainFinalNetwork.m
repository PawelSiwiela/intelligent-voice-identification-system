function net = trainFinalNetwork(X, Y, golden_params)
% Trenuje finalną sieć z Golden Parameters Z OKNEM TRENOWANIA

logInfo('🏆 Trenowanie FINALNEJ sieci z Golden Parameters...');
logInfo('   🧠 Architektura: %s', mat2str(golden_params.hidden_layers));
logInfo('   ⚙️ Funkcja treningu: %s', golden_params.train_function);
logInfo('   📈 Learning rate: %.4f', golden_params.learning_rate);

% ===== TWORZENIE SIECI =====
net = patternnet(golden_params.hidden_layers, golden_params.train_function);

% ===== USTAWIENIA TRENINGU Z OKNEM! =====
net.trainParam.showWindow = true;         % ✅ WŁĄCZ okno trenowania!
net.trainParam.showCommandLine = false;    % ✅ WŁĄCZ command line
net.plotFcns = {'plotperform', 'plottrainstate', 'plotconfusion', 'plotroc'};
% Parametry trenowania z Golden Parameters
net.trainParam.lr = golden_params.learning_rate;
net.trainParam.epochs = golden_params.epochs;

% Funkcja aktywacji
for i = 1:length(net.layers)
    if i < length(net.layers)
        net.layers{i}.transferFcn = golden_params.activation_function;
    end
end

% ===== PODZIAŁ DANYCH =====
net.divideParam.trainRatio = 0.8;
net.divideParam.valRatio = 0.15;
net.divideParam.testRatio = 0.05;

% ===== TRENOWANIE Z OKNEM =====
logInfo('🚀 Rozpoczynam trenowanie finalnej sieci...');
logInfo('📱 OKNO TRENOWANIA zostanie wyświetlone!');

try
    [net, ~] = train(net, X', Y');
    logSuccess('✅ Finalna sieć wytrenowana pomyślnie z oknem!');
    
catch ME
    logError('❌ Błąd trenowania finalnej sieci: %s', ME.message);
    rethrow(ME);
end

end