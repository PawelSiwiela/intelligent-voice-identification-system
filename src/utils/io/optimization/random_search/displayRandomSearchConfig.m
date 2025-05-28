function displayRandomSearchConfig(config, X, Y, labels)
% =========================================================================
% WYŚWIETLANIE KONFIGURACJI RANDOM SEARCH
% =========================================================================

logInfo('');
logInfo('🎲 ===== KONFIGURACJA RANDOM SEARCH =====');
logInfo('📊 Rozmiar danych: %d próbek, %d cech, %d kategorii', ...
    size(X,1), size(X,2), length(labels));
logInfo('🔄 Maksimum iteracji: %d', config.max_iterations);
logInfo('📈 Learning rates: %d opcji [%.3f - %.3f]', ...
    length(config.learning_rates), min(config.learning_rates), max(config.learning_rates));
logInfo('🧠 Architektury: %d opcji', length(config.hidden_layers_options));
logInfo('⚙️ Funkcje treningu: %d opcji (%s)', ...
    length(config.training_functions), strjoin(config.training_functions, ', '));
logInfo('🎯 Cel: znaleźć Golden Parameters (95%%+)');
logInfo('⏰ Timeout per iteracja: %d sekund', config.timeout_per_iteration);

% Obliczenie możliwych kombinacji
total_combinations = length(config.learning_rates) * ...
    length(config.hidden_layers_options) * ...
    length(config.training_functions) * ...
    length(config.activation_functions) * ...
    length(config.epochs_range);

hit_probability = config.max_iterations / total_combinations * 100;

logInfo('📊 Możliwych kombinacji: %d', total_combinations);
logInfo('📈 Pokrycie przestrzeni: %.4f%%', hit_probability);
logInfo('==========================================');
logInfo('');

end