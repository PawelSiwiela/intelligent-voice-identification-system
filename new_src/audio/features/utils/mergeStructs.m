function merged = mergeStructs(struct1, struct2, prefix)
% MERGESTRUCTS Łączy dwie struktury, dodając prefiks do pól drugiej struktury
%
% Składnia:
%   merged = mergeStructs(struct1, struct2, prefix)
%
% Argumenty:
%   struct1 - pierwsza struktura (bazowa)
%   struct2 - druga struktura (do dodania)
%   prefix - prefiks dodawany do pól drugiej struktury (np. 'basic_')
%
% Zwraca:
%   merged - połączona struktura z prefiksami

% Kopiowanie pierwszej struktury jako baza
merged = struct1;

% Jeśli druga struktura jest pusta, zakończ
if isempty(struct2) || ~isstruct(struct2)
    return;
end

% Dodaj prefiks dla odróżnienia pól (opcjonalnie)
if nargin < 3 || isempty(prefix)
    use_prefix = false;
else
    use_prefix = true;
    % Upewnij się, że prefiks kończy się podkreślnikiem
    if prefix(end) ~= '_'
        prefix = [prefix '_'];
    end
end

% Pobierz nazwy pól drugiej struktury
fields = fieldnames(struct2);

% Dodaj każde pole z drugiej struktury do wynikowej
for i = 1:length(fields)
    field_name = fields{i};
    
    % Dodaj prefiks do nazwy pola, jeśli wymagane
    if use_prefix
        new_field_name = [prefix field_name];
    else
        new_field_name = field_name;
    end
    
    % Dodaj pole do wynikowej struktury
    merged.(new_field_name) = struct2.(field_name);
end
end