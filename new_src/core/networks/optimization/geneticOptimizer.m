function [best_net, best_tr, results] = geneticOptimizer(X, Y, labels, config)
% GENETICOPTIMIZER Optymalizacja sieci neuronowej algorytmem genetycznym
%
% Składnia:
%   [best_net, best_tr, results] = geneticOptimizer(X, Y, labels, config)
%
% Argumenty:
%   X - macierz cech (próbki × cechy)
%   Y - macierz etykiet one-hot (próbki × klasy)
%   labels - wektor etykiet tekstowych
%   config - struktura konfiguracyjna
%
% Zwraca:
%   best_net - najlepsza znaleziona sieć
%   best_net_type - typ najlepszej sieci ('patternnet' lub 'feedforwardnet')
%   best_tr - dane treningu najlepszej sieci
%   results - struktura z wynikami optymalizacji

% Ustawienie domyślnych parametrów algorytmu genetycznego
if ~isfield(config, 'population_size')
    config.population_size = 10;  % Rozmiar populacji
end

if ~isfield(config, 'num_generations')
    config.num_generations = 4;   % Liczba generacji (population_size * num_generations ≈ max_trials)
end

if ~isfield(config, 'mutation_rate')
    config.mutation_rate = 0.2;   % Prawdopodobieństwo mutacji
end

if ~isfield(config, 'crossover_rate')
    config.crossover_rate = 0.8;  % Prawdopodobieństwo krzyżowania
end

if ~isfield(config, 'elite_count')
    config.elite_count = 2;       % Liczba najlepszych osobników przechodzących bez zmian
end

if ~isfield(config, 'selection_method')
    config.selection_method = 'tournament';  % Metoda selekcji ('roulette', 'tournament')
end

if ~isfield(config, 'tournament_size')
    config.tournament_size = 3;   % Rozmiar turnieju (dla selekcji turniejowej)
end

% Informacje o danych
num_samples = size(X, 1);
num_features = size(X, 2);
num_classes = size(Y, 2);

logInfo('📊 Dane: %d próbek, %d cech, %d klas', num_samples, num_features, num_classes);

% Definiowanie zakresu parametrów do optymalizacji
param_ranges = defineParameterRanges(config);

% Inicjalizacja populacji początkowej
logInfo('🧬 Inicjalizacja populacji początkowej (rozmiar=%d)...', config.population_size);
population = initializePopulation(config.population_size, param_ranges);

% Inicjalizacja zmiennych do śledzenia najlepszych wyników
best_accuracy = 0;
best_net = [];
best_tr = [];
best_params = [];
golden_found = false;
all_results = [];
trial_counter = 0;

logInfo('🧬 Rozpoczynam optymalizację genetyczną (populacja=%d, generacje=%d)...', ...
    config.population_size, config.num_generations);

% Główna pętla algorytmu genetycznego
for gen = 1:config.num_generations
    logInfo('🔄 Generacja %d/%d', gen, config.num_generations);
    
    % Ocena populacji
    fitness = zeros(1, config.population_size);
    nets = cell(1, config.population_size);
    trs = cell(1, config.population_size);
    configs = cell(1, config.population_size);
    
    % Równoległa ocena populacji (jeśli dostępny Parallel Computing Toolbox)
    parfor_progress_available = exist('parfor_progress', 'file') == 2;
    
    if parfor_progress_available
        parfor_progress(config.population_size);
    end
    
    for i = 1:config.population_size
        trial_counter = trial_counter + 1;
        
        % Konwersja genotypu osobnika na parametry sieci
        individual = population(i);
        net_config = convertToNetworkConfig(individual, param_ranges);
        configs{i} = net_config;
        
        % Wyświetlenie informacji o aktualnej konfiguracji
        if isfield(net_config, 'hidden_layers') && ~isempty(net_config.hidden_layers)
            hidden_str = arrayToString(net_config.hidden_layers);
        else
            hidden_str = '[]';
        end
        
        trial_name = sprintf('%s_%s_%s', net_config.type, hidden_str, net_config.training_algorithm);
        
        logInfo('🔄 Próba %d/%d (Gen %d, Osobnik %d): %s (lr=%.5f, epoki=%d)', ...
            trial_counter, config.population_size * config.num_generations, ...
            gen, i, trial_name, net_config.learning_rate, net_config.max_epochs);
        
        % Utworzenie i trenowanie sieci
        try
            % Dodaj potrzebne pola konfiguracyjne
            net_config.X_test = config.X_test;
            net_config.Y_test = config.Y_test;
            
            % Tworzenie nowej sieci według podanej konfiguracji
            net = createNetwork(net_config);
            
            % Trenowanie sieci
            [net, tr, training_results] = trainNetwork(net, X, Y, net_config);
            
            % Zapisanie wyników
            fitness(i) = training_results.accuracy;
            nets{i} = net;
            trs{i} = tr;
            
            % Dodanie wyników do całkowitej listy
            config_result = struct(...
                'accuracy', training_results.accuracy, ...
                'training_time', training_results.training_time, ...
                'network_config', net_config, ...
                'generation', gen, ...
                'individual', i);
            
            all_results = [all_results, config_result];
            
            % Aktualizacja najlepszego wyniku
            if training_results.accuracy > best_accuracy
                best_accuracy = training_results.accuracy;
                best_net = net;
                best_tr = tr;
                best_params = net_config;
                
                logSuccess('🏆 Nowy najlepszy wynik: %.2f%% (czas: %.2fs)', ...
                    best_accuracy * 100, training_results.training_time);
                
                % Sprawdzenie "złotej dokładności"
                if best_accuracy >= config.golden_accuracy && ~golden_found
                    golden_found = true;
                    logSuccess('🥇 Znaleziono "złotą dokładność" (%.2f%%)!', best_accuracy * 100);
                end
            end
            
        catch e
            % W przypadku błędu podczas trenowania
            logError('❌ Błąd podczas trenowania osobnika %d w generacji %d: %s', ...
                i, gen, e.message);
            
            % Przypisanie niskiej wartości fitness dla błędnego osobnika
            fitness(i) = 0.01;  % minimalna wartość by uniknąć problemów z selekcją
        end
        
        % Aktualizacja paska postępu (jeśli dostępny)
        if parfor_progress_available
            parfor_progress;
        end
    end
    
    % Zakończenie paska postępu
    if parfor_progress_available
        parfor_progress(0);
    end
    
    % Sprawdzenie warunku przerwania
    if golden_found && isfield(config, 'early_stopping') && config.early_stopping
        logInfo('🛑 Zatrzymuję algorytm genetyczny wcześniej - znaleziono złotą dokładność');
        break;
    end
    
    % Selekcja osobników do nowej populacji
    selected_indices = selectIndividuals(fitness, config);
    
    % Tworzenie nowej populacji przez krzyżowanie i mutację
    new_population = zeros(size(population));
    
    % Elityzm - przeniesienie najlepszych osobników bez zmian
    [~, elite_indices] = sort(fitness, 'descend');
    elite_indices = elite_indices(1:min(config.elite_count, length(elite_indices)));
    
    for e = 1:length(elite_indices)
        new_population(e, :) = population(elite_indices(e), :);
    end
    
    % Wypełnienie reszty populacji przez krzyżowanie i mutację
    for j = length(elite_indices)+1:config.population_size
        % Wybór rodziców
        parent1_idx = selected_indices(randi(length(selected_indices)));
        parent2_idx = selected_indices(randi(length(selected_indices)));
        
        % Krzyżowanie
        if rand() < config.crossover_rate
            child = crossover(population(parent1_idx, :), population(parent2_idx, :));
        else
            % Jeśli nie ma krzyżowania, wybierz losowo jednego rodzica
            if rand() < 0.5
                child = population(parent1_idx, :);
            else
                child = population(parent2_idx, :);
            end
        end
        
        % Mutacja
        child = mutate(child, param_ranges, config.mutation_rate);
        
        % Dodanie do nowej populacji
        new_population(j, :) = child;
    end
    
    % Aktualizacja populacji
    population = new_population;
    
    logInfo('✓ Zakończono generację %d/%d. Najlepszy wynik: %.2f%%', ...
        gen, config.num_generations, best_accuracy * 100);
end

logSuccess('✅ Optymalizacja genetyczna zakończona. Najlepsza dokładność: %.2f%%', best_accuracy * 100);

% Przygotowanie struktury wynikowej
[~, idx] = sort([all_results.accuracy], 'descend');

if ~isempty(idx)
    sorted_results = all_results(idx);
else
    sorted_results = [];
end

results = struct(...
    'best_accuracy', best_accuracy, ...
    'best_params', best_params, ...
    'all_results', sorted_results);

end

function str = arrayToString(arr)
% Konwertuje tablicę na string, np. [1 2 3] -> "[1 2 3]"
str = ['[' sprintf('%d ', arr) ']'];
str = strtrim(str);
if length(arr) > 1
    str(end) = ']';
else
    str = [str ']'];
end
end