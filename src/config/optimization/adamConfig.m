function config = adamConfig()
% =========================================================================
% KONFIGURACJA OPTYMALIZATORA ADAM - WERSJA ZBALANSOWANA
% =========================================================================

config = struct();

% Metoda
config.method = 'adam';

% Parametry optymalizacji
config.max_iterations = 120;  % ✅ Lekko zwiększ z 100

% Hiperparametry - SKUPIONE NA NAJLEPSZYCH ZAKRESACH
config.learning_rates = [
    0.002, 0.003, 0.004, 0.005, ...  % Wokół 0.003 (94.1%)
    0.008, 0.01, 0.012, 0.015, ...   % Wokół 0.01
    0.06, 0.07, 0.08, 0.09           % Wokół 0.08 (94.6%)
    ];

% Architektury sieci - ROZSZERZONE WOKÓŁ NAJLEPSZYCH
config.hidden_layers_options = {
    % Single layers - szczegółowe wokół najlepszych
    [12], [13], [14], [15], [16], [17], [18], ...  % Wokół 15
    [22], [23], [24], [25], [26], [27], [28], ...  % Wokół 25
    [32], [33], [34], [35], [36], [37], [38], ...  % Wokół 35
    };

% Funkcje treningu - PRIORYTET najlepszym
config.train_functions = {
    'trainbr',    % ⭐ NAJLEPSZY - 94.1% i 94.6%
    'trainlm',    % ⭐ DRUGI NAJLEPSZY
    'trainscg',   % Dobry backup
    'traincgb'    % Usuń słabsze opcje
    };

% Funkcje aktywacji
config.activation_functions = {
    'logsig',     % ⭐ NAJLEPSZY dla klasyfikacji
    'tansig'      % Usuń purelin - rzadko dobry
    };

% Parametry treningu - LEPSZE WARTOŚCI
config.epochs_range = [100, 150, 200, 700];  % Więcej epok
config.validation_checks_range = [10, 15];  % Więcej cierpliwości

% Podział danych - ZOPTYMALIZOWANE
config.train_ratios = [0.75, 0.8];   % Więcej danych treningowych
config.val_ratios = [0.15, 0.2];
config.test_ratios = [0.05, 0.1];    % Mniej danych testowych

% Zapisywanie wyników
config.save_results = true;
config.create_plots = false;

% ===== FOCUSED SEARCH - WYSTARCZY TO =====
config.focused_search = true;
config.focused_iterations = 60;  % Zwiększ z 50

% Na podstawie RZECZYWISTYCH najlepszych wyników
config.best_learning_rates = [0.002, 0.003, 0.004, 0.075, 0.08, 0.085];
config.best_layers = {[14], [15], [16], [24], [25], [26], [34], [35], [36]};
config.best_functions = {'trainbr', 'trainlm'};

end