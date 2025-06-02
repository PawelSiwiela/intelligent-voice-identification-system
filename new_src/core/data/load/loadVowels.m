function [X, Y, successful_loads, failed_loads] = loadVowels(X, Y, vowels, num_vowels, ...
    num_samples, simple_path, total_categories, successful_loads, failed_loads, noise_level, feature_dim)
% LOADVOWELS Wczytuje próbki samogłosek
%
% Składnia:
%   [X, Y, successful_loads, failed_loads] = loadVowels(X, Y, vowels, num_vowels, ...
%       num_samples, simple_path, total_categories, successful_loads, failed_loads, noise_level, feature_dim)
%
% Argumenty:
%   X, Y - macierze cech i etykiet
%   vowels - lista samogłosek do wczytania
%   num_vowels - liczba samogłosek
%   num_samples - ile próbek wczytać na samogłoskę
%   simple_path - ścieżka do folderu z samogłoskami
%   total_categories - całkowita liczba kategorii
%   successful_loads, failed_loads - liczniki udanych/nieudanych wczytań
%   noise_level - poziom szumu
%   feature_dim - stały wymiar wektora cech
%
% Zwraca:
%   X, Y - zaktualizowane macierze cech i etykiet
%   successful_loads, failed_loads - zaktualizowane liczniki

% Sprawdzenie istnienia folderu z samogłoskami
if ~exist(simple_path, 'dir')
    logError('❌ Folder z samogłoskami nie istnieje: %s', simple_path);
    error('Folder z samogłoskami nie istnieje: %s', simple_path);
end

logInfo('🔄 Rozpoczynam wczytywanie samogłosek...');

% Przetwarzanie każdej samogłoski
for v = 1:num_vowels
    % Parsowanie nazwy samogłoski i prędkości
    vowel_parts = strsplit(vowels{v}, '/');
    vowel_base = vowel_parts{1};    % np. 'a'
    vowel_speed = vowel_parts{2};   % np. 'normalnie'
    
    % Ścieżka do folderu z daną samogłoską
    vowel_path = fullfile(simple_path, vowel_base, vowel_speed);
    
    if ~exist(vowel_path, 'dir')
        logWarning('⚠️ Folder "%s" nie istnieje. Pomijam samogłoskę %s.', vowel_path, vowels{v});
        continue;
    end
    
    % Pobieranie wszystkich plików .wav
    wav_files = dir(fullfile(vowel_path, '*.wav'));
    
    % Sortowanie plików według numeru
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
        
        % Preprocessing audio z filtracją adaptacyjną i ekstrakcją cech
        try
            [features, ~] = preprocessAudio(file_path, noise_level);
            
            % Walidacja wymiaru cech (musi być zawsze 40)
            if length(features) < feature_dim
                features = [features, zeros(1, feature_dim - length(features))];
            elseif length(features) > feature_dim
                features = features(1:feature_dim);
            end
            
            % Dodanie próbki do zbioru danych
            X = [X; features];
            
            % Utworzenie etykiety one-hot dla kategorii
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