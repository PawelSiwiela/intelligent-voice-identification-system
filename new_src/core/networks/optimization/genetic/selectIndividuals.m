function selected_indices = selectIndividuals(fitness, config)
% SELECTINDIVIDUALS Wybiera osobniki do reprodukcji (tylko metoda turniejowa)
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

% Pobierz rozmiar turnieju lub ustaw domyślny
if ~isfield(config, 'tournament_size') || isempty(config.tournament_size)
    tournament_size = 3;  % Domyślny rozmiar turnieju
else
    tournament_size = config.tournament_size;
end

% Liczba osobników do wybrania
num_to_select = config.population_size;

% Zabezpieczenie przed ujemnymi wartościami fitness
fitness = max(fitness, 0.001);

% Wykonaj selekcję turniejową
selected_indices = tournamentSelection(fitness, num_to_select, tournament_size);
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