function [X, Y, labels, successful_loads, failed_loads] = loadAudioData(noise_level, num_samples, use_vowels, use_complex, normalize_features_flag)
% Funkcja do wczytywania i przetwarzania danych audio
%
% Argumenty:
%   noise_level - poziom szumu (0-1)
%   num_samples - liczba próbek na kategorię
%   use_vowels - czy wczytywać samogłoski
%   use_complex - czy wczytywać komendy złożone
%   normalize_features_flag - czy normalizować cechy (domyślnie true)
%
% Zwraca:
%   X - macierz cech
%   Y - macierz etykiet (one-hot encoding)
%   labels - nazwy kategorii
%   successful_loads - liczba udanych wczytań
%   failed_loads - liczba nieudanych wczytań

% Sprawdzenie czy podano parametr normalizacji
if nargin < 5
    normalize_features_flag = true;  % Domyślnie normalizuj
end

% Samogłoski - podstawowe 3 samogłoski
vowels_base = {'a', 'e', 'i'};

% Dodanie wszystkich kombinacji samogłosek z "normalnie" i "szybko"
vowels = {};
vowel_speed_types = {'normalnie', 'szybko'};

for i = 1:length(vowels_base)
    for j = 1:length(vowel_speed_types)
        full_vowel = sprintf('%s/%s', vowels_base{i}, vowel_speed_types{j});
        vowels{end+1} = full_vowel;
    end
end

num_vowels = length(vowels);  % Teraz będzie 6 (3 samogłoski × 2 prędkości)

% Pary słów - wszystkie 8 podstawowych komend
complex_commands = {
    'Drzwi/Otwórz drzwi', 'Drzwi/Zamknij drzwi', ...
    'Odbiornik/Włącz odbiornik', 'Odbiornik/Wyłącz odbiornik', ...
    'Światło/Włącz światło', 'Światło/Wyłącz światło', ...
    'Temperatura/Zmniejsz temperaturę', 'Temperatura/Zwiększ temperaturę'
    };

% Dodanie wszystkich kombinacji komend z "normalnie" i "szybko"
all_commands = {};
speed_types = {'normalnie', 'szybko'};

for i = 1:length(complex_commands)
    for j = 1:length(speed_types)
        command_parts = strsplit(complex_commands{i}, '/');
        full_command = sprintf('%s/%s/%s', command_parts{1}, command_parts{2}, speed_types{j});
        all_commands{end+1} = full_command;
    end
end

num_commands = length(all_commands);  % Teraz będzie 16

% Określenie całkowitej liczby kategorii
if use_vowels && use_complex
    total_categories = num_vowels + num_commands;
    labels = [vowels, all_commands];
elseif use_vowels
    total_categories = num_vowels;
    labels = vowels;
else
    total_categories = num_commands;
    labels = all_commands;
end

% Inicjalizacja macierzy cech
X = [];  % Macierz cech
Y = [];  % Etykiety (one-hot encoding)

% Sprawdzenie istnienia folderów
current_file_path = mfilename('fullpath');
[current_dir, ~, ~] = fileparts(current_file_path);
simple_path = fullfile(current_dir, 'data', 'simple');
complex_path = fullfile(current_dir, 'data', 'complex');

% Liczniki udanych wczytań
successful_loads = 0;
failed_loads = 0;
sample_count = 0;  % Inicjalizacja licznika próbek

% Utworzenie głównego paska postępu z lepszymi wymiarami
total_samples = ((use_vowels * num_vowels) + (use_complex * num_commands)) * num_samples;
expected_categories = (use_vowels * num_vowels) + (use_complex * num_commands);

h_main = createProgressWindow(total_samples, expected_categories);

% Wczytanie samogłosek
if use_vowels
    if ~exist(simple_path, 'dir')
        error('Folder z samogłoskami nie został znaleziony! Ścieżka: %s', simple_path);
    end
    
    for v = 1:num_vowels
        % Parsowanie nazwy samogłoski z prędkością
        vowel_parts = strsplit(vowels{v}, '/');
        vowel_base = vowel_parts{1};
        vowel_speed = vowel_parts{2};
        
        vowel_path = fullfile(simple_path, vowel_base, vowel_speed);
        
        %fprintf('Przetwarzanie ścieżki samogłoski: %s\n', vowel_path);
        
        if ~exist(vowel_path, 'dir')
            warning('Folder "%s" nie istnieje. Pomijam samogłoskę %s.', vowel_path, vowels{v});
            continue;
        end
        
        for i = 1:num_samples
            % Aktualizacja paska postępu z sprawdzeniem zatrzymania
            sample_count = sample_count + 1;
            category_name = strrep(vowels{v}, '/', ' → ');
            stop_requested = updateProgress(h_main, sample_count, total_samples, ...
                category_name, i, num_samples, successful_loads, failed_loads);
            
            % SPRAWDZENIE ZATRZYMANIA
            if stop_requested
                fprintf('\n🛑 Przetwarzanie zostało zatrzymane przez użytkownika!\n');
                fprintf('Wczytano %d próbek przed zatrzymaniem.\n', successful_loads);
                
                if isvalid(h_main)
                    close(h_main);
                end
                
                % Zwróć to co już się udało wczytać (jeśli coś jest)
                if ~isempty(X)
                    config_string = 'partial'; % Oznacz jako niepełne
                    if normalize_features_flag
                        data_filename = sprintf('loaded_audio_data_%s_normalized_PARTIAL.mat', config_string);
                    else
                        data_filename = sprintf('loaded_audio_data_%s_raw_PARTIAL.mat', config_string);
                    end
                    
                    save(data_filename, 'X', 'Y', 'labels', 'successful_loads', 'failed_loads');
                    fprintf('Częściowe dane zapisane jako: %s\n', data_filename);
                end
                
                return; % Wyjście z funkcji
            end
            
            % Pełna ścieżka do pliku
            file_path = fullfile(vowel_path, sprintf('Dźwięk %d.wav', i));
            
            try
                [features, feature_names] = preprocessAudio(file_path, noise_level);
                
                % Sprawdzenie wymiarów przed konkatenacją
                if isempty(X)
                    X = features;
                    %fprintf('Inicjalizacja X z rozmiarem: %d cech\n', length(features));
                else
                    if length(features) ~= size(X, 2)
                        warning('Niezgodność wymiarów! Oczekiwano %d cech, otrzymano %d dla pliku %s', ...
                            size(X,2), length(features), file_path);
                        continue;
                    end
                    X = [X; features];
                end
                
                % Sprawdzenie indeksu przed utworzeniem etykiety
                if v > total_categories
                    error('Błąd indeksowania: próba dostępu do indeksu %d gdy total_categories = %d', ...
                        v, total_categories);
                end
                
                label = zeros(1, total_categories);
                label(v) = 1;
                Y = [Y; label];
                successful_loads = successful_loads + 1;
                
            catch ME
                failed_loads = failed_loads + 1;
                warning('Problem z przetworzeniem pliku %s: %s', file_path, ME.message);
            end
        end
    end
end

% Wczytanie par słów
if use_complex
    if ~exist(complex_path, 'dir')
        error('Folder z komendami złożonymi nie został znaleziony! Ścieżka: %s', complex_path);
    end
    
    for c = 1:num_commands
        % Używamy all_commands zamiast complex_commands
        command_parts = strsplit(all_commands{c}, '/');
        % Budujemy ścieżkę używając wszystkich części z all_commands
        command_path = fullfile(complex_path, command_parts{1}, command_parts{2}, command_parts{3});
        
        % fprintf('Przetwarzanie ścieżki: %s\n', command_path);
        
        if ~exist(command_path, 'dir')
            warning('Folder "%s" nie istnieje. Pomijam komendę %s.', command_path, all_commands{c});
            continue;
        end
        
        for i = 1:num_samples
            % Aktualizacja paska postępu z sprawdzeniem zatrzymania
            sample_count = sample_count + 1;
            category_name = strrep(all_commands{c}, '/', ' → ');
            stop_requested = updateProgress(h_main, sample_count, total_samples, ...
                category_name, i, num_samples, successful_loads, failed_loads);
            
            % SPRAWDZENIE ZATRZYMANIA
            if stop_requested
                fprintf('\n🛑 Przetwarzanie zostało zatrzymane przez użytkownika!\n');
                fprintf('Wczytano %d próbek przed zatrzymaniem.\n', successful_loads);
                
                if isvalid(h_main)
                    close(h_main);
                end
                
                % Zwróć to co już się udało wczytać
                if ~isempty(X)
                    config_string = 'partial';
                    if normalize_features_flag
                        data_filename = sprintf('loaded_audio_data_%s_normalized_PARTIAL.mat', config_string);
                    else
                        data_filename = sprintf('loaded_audio_data_%s_raw_PARTIAL.mat', config_string);
                    end
                    
                    save(data_filename, 'X', 'Y', 'labels', 'successful_loads', 'failed_loads');
                    fprintf('Częściowe dane zapisane jako: %s\n', data_filename);
                end
                
                return;
            end
            
            % Pełna ścieżka do pliku
            file_path = fullfile(command_path, sprintf('Dźwięk %d.wav', i));
            
            try
                [features, feature_names] = preprocessAudio(file_path, noise_level);
                
                % Sprawdzenie wymiarów przed konkatenacją
                if isempty(X)
                    X = features;
                    fprintf('Inicjalizacja X z rozmiarem: %d cech\n', length(features));
                else
                    if length(features) ~= size(X, 2)
                        warning('Niezgodność wymiarów! Oczekiwano %d cech, otrzymano %d dla pliku %s', ...
                            size(X,2), length(features), file_path);
                        continue;
                    end
                    X = [X; features];
                end
                
                % POPRAWKA: Użycie właściwego indeksu w zależności od tego, czy używamy samogłosek
                if use_vowels
                    label_index = num_vowels + c;
                else
                    label_index = c;  % Bez dodawania num_vowels gdy nie używamy samogłosek
                end
                
                % Sprawdzenie indeksu przed utworzeniem etykiety
                if label_index > total_categories
                    error('Błąd indeksowania: próba dostępu do indeksu %d gdy total_categories = %d', ...
                        label_index, total_categories);
                end
                
                label = zeros(1, total_categories);
                label(label_index) = 1;
                Y = [Y; label];
                successful_loads = successful_loads + 1;
                
            catch ME
                failed_loads = failed_loads + 1;
                warning('Problem z przetworzeniem pliku %s: %s', file_path, ME.message);
            end
        end
    end
end

if isvalid(h_main)
    % Pokaż finalne statystyki przez chwilę
    updateProgress(h_main, total_samples, total_samples, ...
        'Zakończono!', num_samples, num_samples, successful_loads, failed_loads);
    
    % Zmień tytuł na zakończenie
    set(h_main, 'Name', '✅ Przetwarzanie Zakończone');
    
    % Poczekaj chwilę i zamknij
    pause(1.5);
    close(h_main);
end

% Sprawdzenie czy mamy wystarczająco danych
if successful_loads < 10
    warning('Zbyt mało próbek do analizy! Wczytano tylko %d próbek.', successful_loads);
end

fprintf('\nStatystyki wczytywania:\n');
fprintf('Udane wczytania: %d\n', successful_loads);
fprintf('Nieudane wczytania: %d\n', failed_loads);

% Tworzenie unikalnej nazwy pliku na podstawie konfiguracji
config_string = '';
if use_vowels && use_complex
    config_string = 'vowels_complex';
elseif use_vowels
    config_string = 'vowels_only';
elseif use_complex
    config_string = 'complex_only';
else
    config_string = 'empty';
end

% Użyj konfiguracji w nazwie pliku
if normalize_features_flag
    data_filename = sprintf('loaded_audio_data_%s_normalized.mat', config_string);
    normalization_status = 'znormalizowane';
else
    data_filename = sprintf('loaded_audio_data_%s_raw.mat', config_string);
    normalization_status = 'nieznormalizowane';
end

% Normalizacja cech (opcjonalna)
if ~isempty(X)
    if normalize_features_flag
        fprintf('Normalizacja cech...\n');
        X = normalizeFeatures(X);
    else
        fprintf('Pomijanie normalizacji cech...\n');
    end
    
    % Zapisanie danych z informacją o normalizacji
    save(data_filename, 'X', 'Y', 'labels', 'feature_names', ...
        'successful_loads', 'failed_loads', 'normalize_features_flag', ...
        'normalization_status', 'noise_level', 'num_samples', ...
        'use_vowels', 'use_complex');
    
    fprintf('Dane zostały zapisane do pliku %s (cechy: %s)\n', data_filename, normalization_status);
else
    error('Nie udało się wczytać żadnych danych!');
end

end