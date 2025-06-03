function app()
% APP Prosta aplikacja konsolowa do rozpoznawania głosu
%
% Aplikacja umożliwiająca wybór różnych scenariuszy rozpoznawania głosu
% oraz obserwowanie wyników działania systemu przez interfejs konsolowy.

% Czyszczenie konsoli
clc;

% Tytuł aplikacji
printHeader('SYSTEM ROZPOZNAWANIA GŁOSU');

% Inicjalizacja konfiguracji
config = struct();

% ===== WYBÓR SCENARIUSZA =====
fprintf('KROK 1: Wybór scenariusza\n');
fprintf('1 - Wszystkie dane (samogłoski + komendy)\n');
fprintf('2 - Tylko samogłoski\n');
fprintf('3 - Tylko komendy\n');
fprintf('Wybierz opcję [1-3]: ');
scenarioChoice = input('');

switch scenarioChoice
    case 1
        config.scenario = 'all';
        fprintf('✓ Wybrano: wszystkie dane (samogłoski + komendy)\n');
    case 2
        config.scenario = 'vowels';
        fprintf('✓ Wybrano: tylko samogłoski\n');
    case 3
        config.scenario = 'commands';
        fprintf('✓ Wybrano: tylko komendy\n');
    otherwise
        config.scenario = 'all'; % Domyślnie
        fprintf('⚠ Nieprawidłowy wybór. Ustawiam domyślnie: wszystkie dane\n');
end

fprintf('\n');

% ===== NORMALIZACJA CECH =====
fprintf('KROK 2: Normalizacja cech\n');
fprintf('1 - Tak (zalecane)\n');
fprintf('2 - Nie\n');
fprintf('Czy normalizować cechy? [1-2]: ');
normChoice = input('');

switch normChoice
    case 1
        config.normalize_features = true;
        fprintf('✓ Wybrano: normalizacja włączona\n');
    case 2
        config.normalize_features = false;
        fprintf('✓ Wybrano: normalizacja wyłączona\n');
    otherwise
        config.normalize_features = true; % Domyślnie
        fprintf('⚠ Nieprawidłowy wybór. Ustawiam domyślnie: normalizacja włączona\n');
end

fprintf('\n');

% ===== SELEKCJA CECH =====
fprintf('KROK 3: Strategia wyboru cech\n');
fprintf('1 - Zalecany zestaw cech\n');
fprintf('2 - Wszystkie dostępne cechy (40 cech)\n');
fprintf('3 - Pozwól mi wybrać liczbę cech\n');
fprintf('Wybierz strategię [1-3]: ');
featureChoice = input('');

switch featureChoice
    case 1
        config.feature_selection = 'optimized';
        fprintf('✓ Wybrano: automatyczna selekcja cech\n');
        
    case 2
        config.feature_selection = 'all';
        fprintf('✓ Wybrano: wszystkie 40 cech\n');
        
    case 3
        config.feature_selection = 'custom';
        fprintf('Ile cech chcesz użyć (10-40)? ');
        num_features = input('');
        if num_features >= 10 && num_features <= 40
            config.desired_features = num_features;
            fprintf('✓ Wybrano: %d najważniejszych cech\n', num_features);
        else
            config.feature_selection = 'optimized';
            fprintf('⚠ Nieprawidłowa liczba. Ustawiam automatyczną selekcję\n');
        end
        
    otherwise
        config.feature_selection = 'optimized';
        fprintf('⚠ Nieprawidłowy wybór. Ustawiam automatyczną selekcję\n');
end

fprintf('\n');

% ===== POZIOM ZŁOŻONOŚCI ALGORYTMU =====
fprintf('KROK 4: Poziom złożoności obliczeń\n');
fprintf('1 - Niski (szybkie działanie, niższa dokładność)\n');
fprintf('2 - Średni (zalecany)\n');
fprintf('3 - Wysoki (dokładniejszy, ale wolny)\n');
fprintf('Wybierz poziom złożoności [1-3]: ');
complexityChoice = input('');

% Ustawienie parametrów algorytmu genetycznego w zależności od wybranego poziomu
switch complexityChoice
    case 1 % Niski poziom złożoności
        config.population_size = 8;
        config.num_generations = 3;
        config.mutation_rate = 0.2;
        config.crossover_rate = 0.8;
        fprintf('✓ Wybrano: niski poziom złożoności\n');
        
    case 2 % Średni poziom złożoności - zalecany
        config.population_size = 12;
        config.num_generations = 5;
        config.mutation_rate = 0.2;
        config.crossover_rate = 0.8;
        fprintf('✓ Wybrano: średni poziom złożoności\n');
        
    case 3 % Wysoki poziom złożoności
        config.population_size = 20;
        config.num_generations = 8;
        config.mutation_rate = 0.15;
        config.crossover_rate = 0.85;
        fprintf('✓ Wybrano: wysoki poziom złożoności\n');
        
    otherwise % Domyślnie - średni
        config.population_size = 12;
        config.num_generations = 5;
        config.mutation_rate = 0.2;
        config.crossover_rate = 0.8;
        fprintf('⚠ Nieprawidłowy wybór. Ustawiam domyślnie: średni poziom złożoności\n');
end

fprintf('\n');

% ===== PODSUMOWANIE KONFIGURACJI =====
printHeader('PODSUMOWANIE KONFIGURACJI');
fprintf('Scenariusz: %s\n', getScenarioName(config.scenario));
fprintf('Normalizacja cech: %s\n', getYesNo(config.normalize_features));
fprintf('Strategia cech: %s\n', getFeatureSelectionName(config.feature_selection, config)); % POPRAWKA!
fprintf('Poziom złożoności: %s (pop=%d, gen=%d)\n', getComplexityName(complexityChoice), ...
    config.population_size, config.num_generations);
fprintf('\n');

% ===== DODATKOWE PARAMETRY =====
config.optimization_method = 'genetic';
config.elite_count = 2;
config.tournament_size = 4;
config.early_stopping = true;
config.golden_accuracy = 0.95;
config.show_visualizations = true;
config.generate_visualizations = true; % DODAJ TO!
config.noise_level = 0.1;
config.num_samples = 10;

% ===== URUCHOMIENIE SYSTEMU =====
fprintf('Czy uruchomić system z powyższymi ustawieniami? (t/n): ');
startChoice = input('', 's');

if strcmpi(startChoice, 't') || strcmpi(startChoice, 'tak')
    printHeader('ROZPOCZYNAM ROZPOZNAWANIE GŁOSU');
    
    % Uruchomienie głównej funkcji
    try
        tic;
        [best_net, best_tr, results] = voiceRecognition(config);
        elapsed_time = toc;
        
        % Wyświetlenie podsumowania
        printHeader('WYNIKI');
        fprintf('Czas wykonania: %.2f sekund\n', elapsed_time);
        fprintf('Najlepszy typ sieci: %s\n', results.best_network_type);
        fprintf('Najlepsza dokładność: %.2f%%\n', results.best_accuracy * 100);
        fprintf('Metoda optymalizacji: %s\n', config.optimization_method);
        
    catch e
        % Obsługa błędów
        fprintf('\n❌ BŁĄD: %s\n', e.message);
        if ~isempty(e.stack)
            fprintf('Ścieżka: %s\n', e.stack(1).name);
            fprintf('Linia: %d\n', e.stack(1).line);
        end
    end
else
    fprintf('Anulowano uruchomienie.\n');
end

end

% Funkcja pomocnicza do wyświetlania nagłówków
function printHeader(text)
fprintf('\n%s\n', repmat('=', 1, 50));
fprintf('%s\n', text);
fprintf('%s\n\n', repmat('=', 1, 50));
end

% Funkcja zwracająca czytelną nazwę scenariusza
function name = getScenarioName(scenario)
switch scenario
    case 'all'
        name = 'Wszystkie dane (samogłoski + komendy)';
    case 'vowels'
        name = 'Tylko samogłoski';
    case 'commands'
        name = 'Tylko komendy';
    otherwise
        name = scenario;
end
end

% Funkcja zwracająca 'Tak' lub 'Nie'
function result = getYesNo(value)
if value
    result = 'Tak';
else
    result = 'Nie';
end
end

% Funkcja zwracająca nazwę poziomu złożoności
function name = getComplexityName(level)
switch level
    case 1
        name = 'Niski';
    case 2
        name = 'Średni';
    case 3
        name = 'Wysoki';
    otherwise
        name = 'Średni (domyślny)';
end
end

% DODAJ NA KOŃCU: Nową funkcję helper
function name = getFeatureSelectionName(selection_type, config)
switch selection_type
    case 'optimized'
        name = 'Automatyczna selekcja (zoptymalizowane)';
    case 'all'
        name = 'Wszystkie dostępne cechy (40 cech)';
    case 'custom'
        if isfield(config, 'desired_features')
            name = sprintf('Wybrane przez użytkownika (%d cech)', config.desired_features);
        else
            name = 'Wybrane przez użytkownika';
        end
    otherwise
        name = selection_type;
end
end