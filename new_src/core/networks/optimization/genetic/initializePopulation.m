function population = initializePopulation(population_size, param_ranges)
% INITIALIZEPOPULATION Inicjalizacja populacji początkowej
%
% Składnia:
%   population = initializePopulation(population_size, param_ranges)
%
% Argumenty:
%   population_size - rozmiar populacji
%   param_ranges - struktura z definicjami zakresów parametrów
%
% Zwraca:
%   population - macierz populacji początkowej [osobniki x geny]

% Sprawdzenie czy wszystkie wymagane pola są dostępne
required_fields = {'network_types', 'hidden_layers', 'training_algs', 'activation_functions', 'learning_rates'};
for i = 1:length(required_fields)
    field = required_fields{i};
    if ~isfield(param_ranges, field) || isempty(param_ranges.(field))
        error('Brakujące lub puste pole w param_ranges: %s', field);
    end
end

% Sprawdzenie czy pole num_genes istnieje
if ~isfield(param_ranges, 'num_genes')
    param_ranges.num_genes = 5; % Domyślna liczba genów
    disp('Ostrzeżenie: Brak pola num_genes, ustawiono domyślną wartość 5');
end

% Inicjalizacja populacji o wymiarach [population_size x num_genes]
population = zeros(population_size, param_ranges.num_genes);

% Przed wypełnieniem populacji, wyświetl diagnostykę
disp(['INFO: network_types: ', num2str(length(param_ranges.network_types)), ' elementów']);
disp(['INFO: hidden_layers: ', num2str(length(param_ranges.hidden_layers)), ' elementów']);
disp(['INFO: training_algs: ', num2str(length(param_ranges.training_algs)), ' elementów']);
disp(['INFO: activation_functions: ', num2str(length(param_ranges.activation_functions)), ' elementów']);
disp(['INFO: learning_rates: ', num2str(length(param_ranges.learning_rates)), ' elementów']);
if isfield(param_ranges, 'epochs_range')
    disp(['INFO: epochs_range: ', num2str(length(param_ranges.epochs_range)), ' elementów']);
end

% Wypełnienie populacji losowymi wartościami w odpowiednich zakresach
for i = 1:population_size
    try
        % Gen 1: Typ sieci
        population(i, 1) = randi(length(param_ranges.network_types));
        
        % Gen 2: Warstwy ukryte
        population(i, 2) = randi(length(param_ranges.hidden_layers));
        
        % Gen 3: Algorytm uczenia
        population(i, 3) = randi(length(param_ranges.training_algs));
        
        % Gen 4: Funkcja aktywacji
        population(i, 4) = randi(length(param_ranges.activation_functions));
        
        % Gen 5: Współczynnik uczenia
        population(i, 5) = randi(length(param_ranges.learning_rates));
        
        % Gen 6: Liczba epok (jeśli używana)
        if param_ranges.num_genes >= 6 && isfield(param_ranges, 'epochs_range') && ~isempty(param_ranges.epochs_range)
            population(i, 6) = randi(length(param_ranges.epochs_range));
        end
        
    catch e
        disp(['BŁĄD przy inicjalizacji osobnika ', num2str(i), ': ', e.message]);
        % W przypadku błędu, ustaw wartości domyślne
        population(i, :) = ones(1, param_ranges.num_genes);
    end
end

% Dodatkowe informacje diagnostyczne
disp(['INFO: Utworzono populację o wymiarach: ', num2str(size(population))]);
disp(['INFO: Pierwszy osobnik: [', num2str(population(1, :)), ']']);

end