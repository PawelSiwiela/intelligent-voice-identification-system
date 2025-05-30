function [X, Y, labels, successful_loads, failed_loads] = loadAudioData(noise_level, num_samples, use_vowels, use_complex, normalize_features_flag)
% LOADAUDIODATA Wczytuje i przetwarza dane audio do trenowania
%
% Składnia:
%   [X, Y, labels, successful_loads, failed_loads] = loadAudioData(noise_level, num_samples, use_vowels, use_complex, normalize_features_flag)
%
% Argumenty:
%   noise_level - poziom szumu dodawanego do sygnału (0.0-1.0)
%   num_samples - liczba próbek audio na każdą kategorię
%   use_vowels - flaga: czy wczytywać samogłoski (true/false)
%   use_complex - flaga: czy wczytywać komendy złożone (true/false)
%   normalize_features_flag - flaga: czy normalizować cechy (domyślnie true)
%
% Zwraca:
%   X - macierz cech [próbki × cechy]
%   Y - macierz etykiet one-hot [próbki × kategorie]
%   labels - nazwy kategorii (cell array)
%   successful_loads - liczba pomyślnie wczytanych próbek
%   failed_loads - liczba próbek, których nie udało się wczytać

% Sprawdzenie argumentów wejściowych
if nargin < 5
    normalize_features_flag = true; % Domyślnie normalizuj cechy
end

% Generowanie ustawień konfiguracji
config = struct(...
    'noise_level', noise_level, ...
    'num_samples', num_samples, ...
    'use_vowels', use_vowels, ...
    'use_complex', use_complex, ...
    'normalize', normalize_features_flag);

% Próba wczytania wcześniej przetworzonych danych
[cached_data, cache_exists] = loadCachedData(config);
if cache_exists
    X = cached_data.X;
    Y = cached_data.Y;
    labels = cached_data.labels;
    successful_loads = cached_data.successful_loads;
    failed_loads = cached_data.failed_loads;
    return;
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
    logInfo('🏷️ Używanie %d kategorii: %d samogłosek i %d komend złożonych', total_categories, num_vowels, num_commands);
elseif use_vowels
    total_categories = num_vowels;
    labels = vowels;
    logInfo('🏷️ Używanie %d kategorii samogłosek', total_categories);
else
    total_categories = num_commands;
    labels = all_commands;
    logInfo('🏷️ Używanie %d kategorii komend złożonych', total_categories);
end

% Inicjalizacja macierzy wynikowych
X = [];  % Macierz cech
Y = [];  % Macierz etykiet (one-hot encoding)

% Określenie ścieżek do folderów z danymi
simple_path = fullfile('data', 'simple');   % Ścieżka do samogłosek
complex_path = fullfile('data', 'complex'); % Ścieżka do komend złożonych

% Inicjalizacja liczników
successful_loads = 0;
failed_loads = 0;

logInfo('🎯 Rozpoczynam wczytywanie danych audio...');
logInfo('📊 Konfiguracja: szum=%.2f, próbek=%d, samogłoski=%s, złożone=%s', ...
    noise_level, num_samples, yesno(use_vowels), yesno(use_complex));

% =========================================================================
% WCZYTYWANIE DANYCH
% =========================================================================

% Wczytywanie samogłosek
if use_vowels
    [X, Y, successful_loads, failed_loads] = loadVowels(X, Y, vowels, num_vowels, ...
        num_samples, simple_path, total_categories, successful_loads, failed_loads, noise_level);
end

% Wczytywanie komend złożonych
if use_complex
    [X, Y, successful_loads, failed_loads] = loadCommands(X, Y, all_commands, num_commands, ...
        num_samples, complex_path, total_categories, num_vowels, use_vowels, successful_loads, failed_loads, noise_level);
end

% =========================================================================
% FINALIZACJA PRZETWARZANIA
% =========================================================================

% Sprawdzenie ilości wczytanych danych
if successful_loads < 10
    logWarning('⚠️ Zbyt mało próbek do analizy! Wczytano tylko %d próbek.', successful_loads);
end

% Podsumowanie statystyk
logInfo('📊 Udane wczytania: %d, Nieudane wczytania: %d', successful_loads, failed_loads);

% Normalizacja cech (jeśli wymagana)
if normalize_features_flag && ~isempty(X)
    logInfo('⚖️ Normalizacja cech...');
    % Normalizacja każdej cechy oddzielnie
    [X, norm_params] = normalizeFeatures(X);
    config.norm_params = norm_params;
else
    logInfo('🔧 Pomijanie normalizacji cech...');
end

% Zapis danych do pliku
if ~isempty(X)
    saveProcessedData(X, Y, labels, successful_loads, failed_loads, config);
else
    logError('❌ Nie udało się wczytać żadnych danych!');
    error('Nie udało się wczytać żadnych danych!');
end

end

% =========================================================================
% FUNKCJE POMOCNICZE
% =========================================================================

function result = yesno(flag)
% Konwertuje wartość logiczną na tekst "tak"/"nie"
if flag
    result = 'tak';
else
    result = 'nie';
end
end