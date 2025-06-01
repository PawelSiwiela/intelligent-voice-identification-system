function mutated = mutate(individual, param_ranges, mutation_rate)
% MUTATE Operator mutacji osobnika
%
% Składnia:
%   mutated = mutate(individual, param_ranges, mutation_rate)
%
% Argumenty:
%   individual - genotyp osobnika do mutacji
%   param_ranges - struktura z definicjami zakresów parametrów
%   mutation_rate - prawdopodobieństwo mutacji każdego genu
%
% Zwraca:
%   mutated - genotyp po mutacji

% Inicjalizacja wyniku
mutated = individual;

% Liczba genów
num_genes = length(individual);

% Sprawdzenie czy wszystkie wymagane pola są dostępne
required_fields = {'network_types', 'hidden_layers', 'training_algs', 'activation_functions', 'learning_rates'};
for i = 1:length(required_fields)
    field = required_fields{i};
    if ~isfield(param_ranges, field) || isempty(param_ranges.(field))
        error('Brakujące lub puste pole w param_ranges w funkcji mutate: %s', field);
    end
end

% Maksymalne wartości dla każdego genu - z dodatkowym zabezpieczeniem
max_values = zeros(1, 5); % Inicjalizacja tablicy
max_values(1) = length(param_ranges.network_types);
max_values(2) = length(param_ranges.hidden_layers);
max_values(3) = length(param_ranges.training_algs);
max_values(4) = length(param_ranges.activation_functions);
max_values(5) = length(param_ranges.learning_rates);

% Dodaj maksymalną wartość dla liczby epok (jeśli używana)
if num_genes >= 6 && isfield(param_ranges, 'epochs_range') && ~isempty(param_ranges.epochs_range)
    max_values(6) = length(param_ranges.epochs_range);
end

% Sprawdź czy max_values nie zawiera zer
for i = 1:length(max_values)
    if max_values(i) == 0
        max_values(i) = 1; % Minimalna wartość to 1
        disp(['Ostrzeżenie: Zerowa maksymalna wartość dla genu ', num2str(i), ' - ustawiono na 1']);
    end
end

% Mutacja każdego genu z określonym prawdopodobieństwem
for i = 1:min(num_genes, length(max_values))
    if rand() < mutation_rate
        % Losowa nowa wartość w odpowiednim zakresie
        mutated(i) = randi(max_values(i));
    end
end

end