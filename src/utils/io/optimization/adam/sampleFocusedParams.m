function params = sampleFocusedParams(config, best_params)
% =========================================================================
% LOSOWANIE PARAMETRÓW WOKÓŁ NAJLEPSZYCH WYNIKÓW - POPRAWKA
% =========================================================================

params = struct();

% Learning rate - wokół najlepszego ±50%
best_lr = best_params.learning_rate;
lr_range = [best_lr * 0.5, best_lr * 1.5];
params.learning_rate = lr_range(1) + rand() * (lr_range(2) - lr_range(1));

% Architektury - podobne do najlepszej
best_layers = best_params.hidden_layers;
if length(best_layers) == 1
    % Single layer - testuj sąsiednie rozmiary
    base_size = best_layers(1);
    new_size = base_size + randi([-5, 5]);
    params.hidden_layers = [max(5, new_size)];  % ✅ ZAWSZE ROW VECTOR
elseif length(best_layers) == 2
    % Two layers - modyfikuj oba
    params.hidden_layers = [
        max(5, best_layers(1) + randi([-3, 3])), ...  % ✅ UŻYJ ... dla row vector
        max(5, best_layers(2) + randi([-3, 3]))
        ];
else
    % Zostaw najlepszą architekturę
    params.hidden_layers = best_layers(:)';  % ✅ FORCE ROW VECTOR
end

% Funkcja treningu - preferuj najlepszą, ale czasem testuj inne
if rand() < 0.7
    params.train_function = best_params.train_function;
else
    train_idx = randi(length(config.train_functions));
    params.train_function = config.train_functions{train_idx};
end

% Pozostałe parametry - skopiuj z najlepszych
params.activation_function = best_params.activation_function;
params.epochs = best_params.epochs;
params.validation_checks = best_params.validation_checks;
params.train_ratio = best_params.train_ratio;
params.val_ratio = best_params.val_ratio;
params.test_ratio = best_params.test_ratio;

end