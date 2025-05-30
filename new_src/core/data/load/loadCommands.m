function [X, Y, successful_loads, failed_loads] = loadCommands(X, Y, all_commands, num_commands, num_samples, complex_path, total_categories, num_vowels, use_vowels, successful_loads, failed_loads, noise_level)
% LOADCOMMANDS Wczytywanie i przetwarzanie komend złożonych
%
% Argumenty:
%   X, Y - macierze cech i etykiet (mogą być puste)
%   all_commands - lista komend złożonych
%   num_commands - liczba komend
%   num_samples - maksymalna liczba próbek na kategorię
%   complex_path - ścieżka do folderu z komendami
%   total_categories - całkowita liczba kategorii
%   num_vowels - liczba samogłosek (dla offsetu etykiet)
%   use_vowels - flaga czy używane są samogłoski
%   successful_loads, failed_loads - liczniki sukcesu/porażki
%   noise_level - poziom szumu
%
% Zwraca:
%   X, Y - zaktualizowane macierze cech i etykiet
%   successful_loads, failed_loads - zaktualizowane liczniki

% Sprawdzenie istnienia folderu z komendami złożonymi
if ~exist(complex_path, 'dir')
    logError('❌ Folder z komendami złożonymi nie został znaleziony! Ścieżka: %s', complex_path);
    error('Folder z komendami złożonymi nie został znaleziony! Ścieżka: %s', complex_path);
end

logInfo('🔄 Rozpoczynam wczytywanie komend złożonych...');

% Przetwarzanie każdej komendy
for c = 1:num_commands
    % Parsowanie struktury komendy (kategoria/komenda/prędkość)
    command_parts = strsplit(all_commands{c}, '/');
    
    % Sprawdzenie czy mamy wystarczającą liczbę części
    if length(command_parts) < 3
        logWarning('⚠️ Nieprawidłowy format komendy: %s. Pomijam.', all_commands{c});
        continue;
    end
    
    category = command_parts{1};     % np. 'Światło'
    command = command_parts{2};      % np. 'Włącz światło'
    speed = command_parts{3};        % np. 'normalnie'
    
    % Tworzenie ścieżki do folderu z próbkami
    command_path = fullfile(complex_path, category, command, speed);
    
    % Sprawdzenie istnienia folderu
    if ~exist(command_path, 'dir')
        logWarning('⚠️ Folder "%s" nie istnieje. Pomijam komendę %s.', command_path, all_commands{c});
        continue;
    end
    
    % Sortowanie plików numerycznie
    wav_files = dir(fullfile(command_path, '*.wav'));
    file_names = {wav_files.name};
    file_nums = zeros(size(file_names));
    
    for i = 1:length(file_names)
        % Wyciągnij numer z nazwy pliku (zakładamy format "Dźwięk X.wav")
        num_str = regexp(file_names{i}, '\d+', 'match');
        if ~isempty(num_str)
            file_nums(i) = str2double(num_str{1});
        end
    end
    [~, sort_idx] = sort(file_nums);
    wav_files = wav_files(sort_idx);
    
    % Przetwarzanie próbek dla danej komendy
    logInfo('🔍 Przetwarzanie komendy: %s / %s / %s', category, command, speed);
    
    % Limit liczby próbek
    max_files = min(num_samples, length(wav_files));
    
    for i = 1:max_files
        % Ścieżka do konkretnego pliku audio
        file_path = fullfile(wav_files(i).folder, wav_files(i).name);
        
        logDebug('🎧 Przetwarzanie: %s [%d/%d]', file_path, i, max_files);
        
        % Przetwarzanie pliku audio
        try
            % Używamy naszej funkcji preprocessAudio
            [features, ~] = preprocessAudio(file_path, noise_level);
            
            % Sprawdzenie zgodności wymiarów cech
            if isempty(X)
                X = features;
            else
                % Sprawdzenie i dopasowanie wymiarów
                if length(features) ~= size(X, 2)
                    if length(features) > size(X, 2)
                        % Nowy wektor ma więcej cech - rozszerz X
                        X = [X, zeros(size(X, 1), length(features) - size(X, 2))];
                    else
                        % Nowy wektor ma mniej cech - rozszerz features
                        features = [features, zeros(1, size(X, 2) - length(features))];
                    end
                    
                    logWarning('⚠️ Dopasowano wymiary cech dla pliku %s', file_path);
                end
                
                X = [X; features];
            end
            
            % Obliczenie indeksu etykiety dla komendy
            if use_vowels
                label_index = num_vowels + c; % Dodaj offset dla samogłosek
            else
                label_index = c; % Bezpośredni indeks gdy brak samogłosek
            end
            
            % Tworzenie etykiety one-hot dla komendy
            label = zeros(1, total_categories);
            label(label_index) = 1;
            Y = [Y; label];
            successful_loads = successful_loads + 1;
            logDebug('✅ Sukces: %s', file_path);
            
        catch e
            failed_loads = failed_loads + 1;
            logError('❌ Błąd w pliku %s: %s', file_path, e.message);
        end
    end
end

logInfo('✅ Zakończono wczytywanie komend złożonych: %d udanych, %d nieudanych', successful_loads, failed_loads);
end