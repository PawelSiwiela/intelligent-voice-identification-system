function displayAdamConfig(config, X, Y, labels)
% =========================================================================
% WYŚWIETLENIE KONFIGURACJI ADAM
% =========================================================================

logInfo('🔧 KONFIGURACJA OPTYMALIZATORA ADAM:');
logInfo('=====================================');
logInfo('   🎯 Maksymalne iteracje: %d', config.max_iterations);
logInfo('   📈 Learning rates: %d opcji [%.4f - %.4f]', ...
    length(config.learning_rates), min(config.learning_rates), max(config.learning_rates));
logInfo('   🧠 Architektury: %d opcji', length(config.hidden_layers_options));
logInfo('   🔧 Funkcje treningu: %d opcji', length(config.train_functions));
logInfo('   ⚡ Funkcje aktywacji: %d opcji', length(config.activation_functions));

% Informacje o danych
[num_samples, num_features] = size(X);
num_classes = length(labels);
logInfo('');
logInfo('📈 Dane wejściowe: %d próbek × %d cech → %d klas', ...
    num_samples, num_features, num_classes);

% Przykładowe kombinacje
logInfo('');
logInfo('🎲 Przykładowe kombinacje do przetestowania:');
for i = 1:3
    sample_params = sampleAdamHyperparameters(config);
    logInfo('   %d. lr=%.4f, layers=%s, train=%s', ...
        i, sample_params.learning_rate, ...
        mat2str(sample_params.hidden_layers), sample_params.train_function);
end

end

function result = yesno(value)
if value
    result = 'TAK';
else
    result = 'NIE';
end
end