function child = crossover(parent1, parent2)
% CROSSOVER Operator krzyżowania dwóch osobników
%
% Składnia:
%   child = crossover(parent1, parent2)
%
% Argumenty:
%   parent1 - genotyp pierwszego rodzica
%   parent2 - genotyp drugiego rodzica
%
% Zwraca:
%   child - genotyp potomka

% Liczba genów
num_genes = length(parent1);

% Losowy punkt krzyżowania
crossover_point = randi(num_genes - 1);

% Tworzenie potomka przez połączenie genów obu rodziców
child = zeros(size(parent1));
child(1:crossover_point) = parent1(1:crossover_point);
child(crossover_point+1:end) = parent2(crossover_point+1:end);

end