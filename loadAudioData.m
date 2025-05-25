function [X, Y, labels, successful_loads, failed_loads] = loadAudioData(noise_level, num_samples, use_vowels, use_complex, normalize_features_flag)
% =========================================================================
% WCZYTYWANIE I PRZETWARZANIE DANYCH AUDIO
% =========================================================================
% Funkcja do wczytywania próbek audio, ekstrakcji cech i przygotowania
% danych do trenowania sieci neuronowej
%
% ARGUMENTY:
%   noise_level - poziom szumu dodawanego do sygnału (0.0-1.0)
%   num_samples - liczba próbek audio na każdą kategorię
%   use_vowels - flaga: czy wczytywać samogłoski (true/false)
%   use_complex - flaga: czy wczytywać komendy złożone (true/false)
%   normalize_features_flag - flaga: czy normalizować cechy (domyślnie true)
%
% ZWRACA:
%   X - macierz cech [próbki × cechy]
%   Y - macierz etykiet one-hot [próbki × kategorie]
%   labels - nazwy kategorii (cell array)
%   successful_loads - liczba pomyślnie wczytanych próbek
%   failed_loads - liczba próbek, których nie udało się wczytać
%
% STRUKTURA FOLDERÓW:
%   data/simple/[samogłoska]/[prędkość]/Dźwięk X.wav
%   data/complex/[kategoria]/[komenda]/[prędkość]/Dźwięk X.wav
% =========================================================================

% Sprawdzenie argumentów wejściowych
if nargin < 5
    normalize_features_flag = true; % Domyślnie normalizuj cechy
end

% =========================================================================
% DEFINICJA KATEGORII DANYCH
% =========================================================================

% Samogłoski - podstawowe 3 samogłoski z różnymi prędkościami
vowels_base = {'a', 'e', 'i'};
vowel_speed_types = {'normalnie', 'szybko'};

% Generowanie wszystkich kombinacji samogłosek z prędkościami
vowels = {};
for i = 1:length(vowels_base)
    for j = 1:length(vowel_speed_types)
        full_vowel = sprintf('%s/%s', vowels_base{i}, vowel_speed_types{j});
        vowels{end+1} = full_vowel;
    end
end
num_vowels = length(vowels); % Będzie 6 (3 samogłoski × 2 prędkości)

% Komendy złożone - pary słów z różnymi kategoriami
complex_commands = {
    'Drzwi/Otwórz drzwi', 'Drzwi/Zamknij drzwi', ...
    'Odbiornik/Włącz odbiornik', 'Odbiornik/Wyłącz odbiornik', ...
    'Światło/Włącz światło', 'Światło/Wyłącz światło', ...
    'Temperatura/Zmniejsz temperaturę', 'Temperatura/Zwiększ temperaturę'
    };

% Generowanie wszystkich kombinacji komend z prędkościami
all_commands = {};
speed_types = {'normalnie', 'szybko'};

for i = 1:length(complex_commands)
    for j = 1:length(speed_types)
        command_parts = strsplit(complex_commands{i}, '/');
        full_command = sprintf('%s/%s/%s', command_parts{1}, command_parts{2}, speed_types{j});
        all_commands{end+1} = full_command;
    end
end
num_commands = length(all_commands); % Będzie 16 (8 komend × 2 prędkości)

% =========================================================================
% PRZYGOTOWANIE STRUKTURY DANYCH
% =========================================================================

% Określenie kategorii do wczytania
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

% Inicjalizacja macierzy wynikowych
X = [];  % Macierz cech
Y = [];  % Macierz etykiet (one-hot encoding)

% Określenie ścieżek do folderów z danymi
current_file_path = mfilename('fullpath');
[current_dir, ~, ~] = fileparts(current_file_path);
simple_path = fullfile(current_dir, 'data', 'simple');   % Ścieżka do samogłosek
complex_path = fullfile(current_dir, 'data', 'complex'); % Ścieżka do komend

% Inicjalizacja liczników
successful_loads = 0;
failed_loads = 0;
sample_count = 0;

% =========================================================================
% INICJALIZACJA INTERFEJSU UŻYTKOWNIKA
% =========================================================================

% Obliczenie całkowitej liczby próbek do przetworzenia
total_samples = ((use_vowels * num_vowels) + (use_complex * num_commands)) * num_samples;
expected_categories = (use_vowels * num_vowels) + (use_complex * num_commands);

% Utworzenie okna postępu
h_main = createProgressWindow(total_samples, expected_categories);

% =========================================================================
% WCZYTYWANIE SAMOGŁOSEK
% =========================================================================

if use_vowels
    % Sprawdzenie istnienia folderu z samogłoskami
    if ~exist(simple_path, 'dir')
        error('Folder z samogłoskami nie został znaleziony! Ścieżka: %s', simple_path);
    end
    
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
            warning('Folder "%s" nie istnieje. Pomijam samogłoskę %s.', vowel_path, vowels{v});
            continue;
        end
        
        % Przetwarzanie próbek dla danej samogłoski
        for i = 1:num_samples
            % Aktualizacja paska postępu i sprawdzenie zatrzymania
            sample_count = sample_count + 1;
            category_name = strrep(vowels{v}, '/', ' → ');
            stop_requested = updateProgress(h_main, sample_count, total_samples, ...
                category_name, i, num_samples, successful_loads, failed_loads);
            
            % Sprawdzenie czy użytkownik zażądał zatrzymania
            if stop_requested
                handleUserStop(h_main, X, Y, labels, successful_loads, failed_loads, normalize_features_flag);
                return;
            end
            
            % Ścieżka do konkretnego pliku audio
            file_path = fullfile(vowel_path, sprintf('Dźwięk %d.wav', i));
            
            % Przetwarzanie pliku audio
            try
                [features, ~] = preprocessAudio(file_path, noise_level);
                
                % Sprawdzenie zgodności wymiarów cech
                if isempty(X)
                    X = features;
                else
                    if length(features) ~= size(X, 2)
                        warning('Niezgodność wymiarów! Oczekiwano %d cech, otrzymano %d dla pliku %s', ...
                            size(X,2), length(features), file_path);
                        continue;
                    end
                    X = [X; features];
                end
                
                % Tworzenie etykiety one-hot dla samogłoski
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

% =========================================================================
% WCZYTYWANIE KOMEND ZŁOŻONYCH
% =========================================================================

if use_complex
    % Sprawdzenie istnienia folderu z komendami złożonymi
    if ~exist(complex_path, 'dir')
        error('Folder z komendami złożonymi nie został znaleziony! Ścieżka: %s', complex_path);
    end
    
    % Przetwarzanie każdej komendy
    for c = 1:num_commands
        % Parsowanie struktury komendy (kategoria/komenda/prędkość)
        command_parts = strsplit(all_commands{c}, '/');
        
        % Tworzenie ścieżki do folderu z próbkami
        command_path = fullfile(complex_path, command_parts{1}, command_parts{2}, command_parts{3});
        
        % Sprawdzenie istnienia folderu
        if ~exist(command_path, 'dir')
            warning('Folder "%s" nie istnieje. Pomijam komendę %s.', command_path, all_commands{c});
            continue;
        end
        
        % Przetwarzanie próbek dla danej komendy
        for i = 1:num_samples
            % Aktualizacja paska postępu i sprawdzenie zatrzymania
            sample_count = sample_count + 1;
            category_name = strrep(all_commands{c}, '/', ' → ');
            stop_requested = updateProgress(h_main, sample_count, total_samples, ...
                category_name, i, num_samples, successful_loads, failed_loads);
            
            % Sprawdzenie czy użytkownik zażądał zatrzymania
            if stop_requested
                handleUserStop(h_main, X, Y, labels, successful_loads, failed_loads, normalize_features_flag);
                return;
            end
            
            % Ścieżka do konkretnego pliku audio
            file_path = fullfile(command_path, sprintf('Dźwięk %d.wav', i));
            
            % Przetwarzanie pliku audio
            try
                [features, ~] = preprocessAudio(file_path, noise_level);
                
                % Sprawdzenie zgodności wymiarów cech
                if isempty(X)
                    X = features;
                else
                    if length(features) ~= size(X, 2)
                        warning('Niezgodność wymiarów! Oczekiwano %d cech, otrzymano %d dla pliku %s', ...
                            size(X,2), length(features), file_path);
                        continue;
                    end
                    X = [X; features];
                end
                
                % Obliczenie indeksu etykiety dla komendy
                if use_vowels
                    label_index = num_vowels + c; % Dodaj offset dla samogłosek
                else
                    label_index = c; % Bezpośredni indeks gdy brak samogłosek
                end
                
                % Sprawdzenie poprawności indeksu
                if label_index > total_categories
                    error('Błąd indeksowania: próba dostępu do indeksu %d gdy total_categories = %d', ...
                        label_index, total_categories);
                end
                
                % Tworzenie etykiety one-hot dla komendy
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

% =========================================================================
% FINALIZACJA PRZETWARZANIA
% =========================================================================

% Zakończenie okna postępu
if isvalid(h_main)
    finalizeProgressWindow(h_main, total_samples, num_samples, successful_loads, failed_loads);
end

% Sprawdzenie ilości wczytanych danych
if successful_loads < 10
    warning('Zbyt mało próbek do analizy! Wczytano tylko %d próbek.', successful_loads);
end

% Wyświetlenie statystyk
fprintf('\n📊 Statystyki wczytywania:\n');
fprintf('   ✅ Udane wczytania: %d\n', successful_loads);
fprintf('   ❌ Nieudane wczytania: %d\n', failed_loads);

% =========================================================================
% ZAPIS DANYCH DO PLIKU
% =========================================================================

% Generowanie nazwy pliku na podstawie konfiguracji
config_string = generateConfigString(use_vowels, use_complex);
[data_filename, normalization_status] = generateDataFilename(config_string, normalize_features_flag);

% Normalizacja cech (jeśli włączona)
if ~isempty(X)
    if normalize_features_flag
        fprintf('⚖️ Normalizacja cech...\n');
        X = normalizeFeatures(X);
    else
        fprintf('🔧 Pomijanie normalizacji cech...\n');
    end
    
    % Zapisanie danych wraz z metadanymi
    saveProcessedData(data_filename, X, Y, labels, successful_loads, failed_loads, ...
        normalize_features_flag, normalization_status, noise_level, num_samples, ...
        use_vowels, use_complex);
    
    fprintf('💾 Dane zostały zapisane do pliku %s (cechy: %s)\n', data_filename, normalization_status);
else
    error('❌ Nie udało się wczytać żadnych danych!');
end
end
