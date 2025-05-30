function [X, Y, successful_loads, failed_loads] = loadVowels(X, Y, vowels, num_vowels, num_samples, simple_path, total_categories, successful_loads, failed_loads, noise_level)
% LOADVOWELS Wczytywanie i przetwarzanie samogłosek
%
% Argumenty:
%   X, Y - macierze cech i etykiet (mogą być puste)
%   vowels - lista samogłosek
%   num_vowels - liczba samogłosek
%   num_samples - maksymalna liczba próbek na kategorię
%   simple_path - ścieżka do folderu z samogłoskami
%   total_categories - całkowita liczba kategorii
%   successful_loads, failed_loads - liczniki sukcesu/porażki
%   noise_level - poziom szumu
%
% Zwraca:
%   X, Y - zaktualizowane macierze cech i etykiet
%   successful_loads, failed_loads - zaktualizowane liczniki

% Sprawdzenie istnienia folderu z samogłoskami
if ~exist(simple_path, 'dir')
    logError('❌ Folder z samogłoskami nie został znaleziony! Ścieżka: %s', simple_path);
    error('Folder z samogłoskami nie został znaleziony! Ścieżka: %s', simple_path);
end

logInfo('🔄 Rozpoczynam wczytywanie samogłosek...');

% Przetwarzanie każdej samogłoski
for v = 1:num_vowels
    % Parsowanie nazwy samogłoski i prędkości
    vowel_parts = strsplit(vowels{v}, '/');
    vowel_base = vowel_parts{1};    % np. 'a'
    vowel_speed = vowel_parts{2};   % np. 'normalnie'
    
    % Tworzenie ścieżki do folderu z próbkami
    vowel_path = fullfile(simple_path, vowel_base, vowel_speed);
    
    % Sprawdzenie istnienia folderu
    if ~exist(vowel_path, 'dir')
        logWarning('⚠️ Folder "%s" nie istnieje. Pomijam samogłoskę %s.', vowel_path, vowels{v});
        continue;
    end
    
    % Sortowanie plików numerycznie
    wav_files = dir(fullfile(vowel_path, '*.wav'));
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
    
    % Przetwarzanie próbek dla danej samogłoski
    logInfo('🔍 Przetwarzanie samogłoski: %s / %s', vowel_base, vowel_speed);
    
    % Limit liczby próbek
    max_files = min(num_samples, length(wav_files));
    
    for i = 1:max_files
        % Ścieżka do konkretnego pliku audio
        file_path = fullfile(wav_files(i).folder, wav_files(i).name);
        
        logDebug('🎧 Przetwarzanie: %s [%d/%d]', file_path, i, max_files);
        
        % Przetwarzanie pliku audio
        try
            % Używamy funkcji preprocessAudio
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
            
            % Tworzenie etykiety one-hot dla samogłoski
            label = zeros(1, total_categories);
            label(v) = 1;
            Y = [Y; label];
            successful_loads = successful_loads + 1;
            logDebug('✅ Sukces: %s', file_path);
            
        catch e
            failed_loads = failed_loads + 1;
            logError('❌ Błąd w pliku %s: %s', file_path, e.message);
        end
    end
end

logInfo('✅ Zakończono wczytywanie samogłosek: %d udanych, %d nieudanych', successful_loads, failed_loads);
end