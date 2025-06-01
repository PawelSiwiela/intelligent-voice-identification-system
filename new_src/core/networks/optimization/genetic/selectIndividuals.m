function selected_indices = selectIndividuals(fitness, config)
% SELECTINDIVIDUALS Wybiera osobniki do reprodukcji
%
% Składnia:
%   selected_indices = selectIndividuals(fitness, config)
%
% Argumenty:
%   fitness - wektor wartości przystosowania osobników
%   config - struktura konfiguracyjna z parametrami selekcji
%
% Zwraca:
%   selected_indices - indeksy wybranych osobników

% Sprawdzenie metody selekcji
if ~isfield(config, 'selection_method') || isempty(config.selection_method)
    selection_method = 'tournament';
else
    selection_method = config.selection_method;
end

% Liczba osobników do wybrania (zwykle równa rozmiarowi populacji)
num_to_select = config.population_size;

% Zabezpieczenie przed ujemnymi lub zerowymi wartościami fitness
fitness = max(fitness, 0.001);

switch selection_method
    case 'roulette'
        % Selekcja metodą ruletki
        selected_indices = rouletteSelection(fitness, num_to_select);
        
    case 'tournament'
        % Selekcja turniejowa
        if ~isfield(config, 'tournament_size')
            tournament_size = 3;  % Domyślny rozmiar turnieju
        else
            tournament_size = config.tournament_size;
        end
        selected_indices = tournamentSelection(fitness, num_to_select, tournament_size);
        
    case 'rank'
        % Selekcja rangowa
        selected_indices = rankSelection(fitness, num_to_select);
        
    otherwise
        % Domyślnie selekcja turniejowa
        tournament_size = 3;
        selected_indices = tournamentSelection(fitness, num_to_select, tournament_size);
end

end

function selected = rouletteSelection(fitness, num_to_select)
% Selekcja metodą koła ruletki
total_fitness = sum(fitness);

if total_fitness == 0
    % Jeśli suma fitness = 0, wybierz osobniki losowo
    selected = randi(length(fitness), 1, num_to_select);
    return;
end

% Obliczenie prawdopodobieństw selekcji
probabilities = fitness / total_fitness;
cumulative_prob = cumsum(probabilities);

% Wybór osobników
selected = zeros(1, num_to_select);
for i = 1:num_to_select
    r = rand();
    for j = 1:length(cumulative_prob)
        if r <= cumulative_prob(j)
            selected(i) = j;
            break;
        end
    end
end
end

function selected = tournamentSelection(fitness, num_to_select, tournament_size)
% Selekcja turniejowa
selected = zeros(1, num_to_select);
population_size = length(fitness);

for i = 1:num_to_select
    % Losowe wybranie osobników do turnieju
    tournament_indices = randi(population_size, 1, tournament_size);
    
    % Znalezienie zwycięzcy turnieju (osobnik z największym fitness)
    tournament_fitness = fitness(tournament_indices);
    [~, winner_idx] = max(tournament_fitness);
    
    % Dodanie zwycięzcy do wybranych
    selected(i) = tournament_indices(winner_idx);
end
end

function selected = rankSelection(fitness, num_to_select)
% Selekcja rangowa
[~, rank_indices] = sort(fitness, 'descend');
rank_weights = length(fitness):-1:1;

total_weight = sum(rank_weights);

% Wybór osobników z wagami proporcjonalnymi do rangi
selected = zeros(1, num_to_select);
for i = 1:num_to_select
    r = rand() * total_weight;
    cumulative_weight = 0;
    
    for j = 1:length(rank_weights)
        cumulative_weight = cumulative_weight + rank_weights(j);
        if r <= cumulative_weight
            selected(i) = rank_indices(j);
            break;
        end
    end
end
end