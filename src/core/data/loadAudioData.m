function [X, Y, labels, successful_loads, failed_loads] = loadAudioData(noise_level, num_samples, use_vowels, use_complex, normalize_features_flag)
% LOADAUDIODATA Wczytuje i przetwarza dane audio dla różnych scenariuszy
%
% Składnia:
%   [X, Y, labels, successful_loads, failed_loads] = loadAudioData(noise_level, num_samples, use_vowels, use_complex, normalize_features_flag)
%
% Argumenty:
%   noise_level - poziom szumu do dodania (0.0-1.0)
%   num_samples - liczba próbek na kategorię (domyślnie 10)
%   use_vowels - czy wczytywać samogłoski (true/false)
%   use_complex - czy wczytywać komendy złożone (true/false)
%   normalize_features_flag - czy normalizować cechy (true/false)
%
% Zwraca:
%   X - macierz cech [próbki × 40_cech]
%   Y - macierz etykiet one-hot [próbki × klasy]
%   labels - nazwy kategorii
%   successful_loads, failed_loads - liczniki wczytań

% Walidacja argumentów wejściowych
if nargin < 5
    normalize_features_flag = true;
end

% Stała liczba cech dla wszystkich scenariuszy (zgodność z extractFeatures)
feature_dim = 40;

% Konfiguracja do sprawdzenia cache i zapisywania wyników
config = struct(...
    'noise_level', noise_level, ...
    'num_samples', num_samples, ...
    'use_vowels', use_vowels, ...
    'use_complex', use_complex, ...
    'normalize', normalize_features_flag);

% Próba wczytania wcześniej przetworzonych danych (cache)
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

% Samogłoski: 3 podstawowe × 2 prędkości = 6 kategorii
vowels_base = {'a', 'e', 'i'};
vowel_speed_types = {'normalnie', 'szybko'};

vowels = {};
for i = 1:length(vowels_base)
    for j = 1:length(vowel_speed_types)
        vowels{end+1} = sprintf('%s/%s', vowels_base{i}, vowel_speed_types{j});
    end
end
num_vowels = length(vowels);

% Komendy Smart Home: 8 podstawowych × 2 prędkości = 16 kategorii
complex_commands = {
    'Drzwi/Otwórz drzwi', 'Drzwi/Zamknij drzwi', ...
    'Odbiornik/Włącz odbiornik', 'Odbiornik/Wyłącz odbiornik', ...
    'Światło/Włącz światło', 'Światło/Wyłącz światło', ...
    'Temperatura/Zmniejsz temperaturę', 'Temperatura/Zwiększ temperaturę'
};

all_commands = {};
speed_types = {'normalnie', 'szybko'};
for i = 1:length(complex_commands)
    for j = 1:length(speed_types)
        command_parts = strsplit(complex_commands{i}, '/');
        full_command = sprintf('%s/%s/%s', command_parts{1}, command_parts{2}, speed_types{j});
        all_commands{end+1} = full_command;
    end
end
num_commands = length(all_commands);

% =========================================================================
% KONFIGURACJA SCENARIUSZA
% =========================================================================

% Określenie kategorii do wczytania na podstawie scenariusza
if use_vowels && use_complex
    total_categories = num_vowels + num_commands;
    labels = [vowels, all_commands];
    logInfo('🏷️ Scenariusz: wszystkie dane (%d samogłosek + %d komend = %d kategorii)', ...
        num_vowels, num_commands, total_categories);
        
elseif use_vowels
    total_categories = num_vowels;
    labels = vowels;
    logInfo('🏷️ Scenariusz: tylko samogłoski (%d kategorii)', total_categories);
    
else % use_complex
    total_categories = num_commands;
    labels = all_commands;
    logInfo('🏷️ Scenariusz: tylko komendy (%d kategorii)', total_categories);
end

% =========================================================================
% INICJALIZACJA STRUKTUR DANYCH
% =========================================================================

% Macierze wynikowe z ustalonymi wymiarami
X = zeros(0, feature_dim);          % Cechy: [próbki × 40]
Y = zeros(0, total_categories);     % Etykiety: [próbki × klasy]

% Ścieżki do folderów z danymi
simple_path = fullfile('data', 'simple');
complex_path = fullfile('data', 'complex');

% Liczniki wczytań
successful_loads = 0;
failed_loads = 0;

logInfo('🎯 Rozpoczynam wczytywanie danych audio...');
logInfo('📊 Konfiguracja: szum=%.2f, próbek=%d, samogłoski=%s, komendy=%s', ...
    noise_level, num_samples, yesno(use_vowels), yesno(use_complex));

% =========================================================================
% WCZYTYWANIE DANYCH
% =========================================================================

% Wczytanie samogłosek (jeśli wybrane w scenariuszu)
if use_vowels
    [X, Y, successful_loads, failed_loads] = loadVowels(X, Y, vowels, num_vowels, ...
        num_samples, simple_path, total_categories, successful_loads, failed_loads, noise_level, feature_dim);
end

% Wczytanie komend złożonych (jeśli wybrane w scenariuszu)
if use_complex
    [X, Y, successful_loads, failed_loads] = loadCommands(X, Y, all_commands, num_commands, ...
        num_samples, complex_path, total_categories, num_vowels, use_vowels, successful_loads, failed_loads, noise_level, feature_dim);
end

% =========================================================================
% WALIDACJA I FINALIZACJA
% =========================================================================

% Sprawdzenie ilości wczytanych danych
if successful_loads < 10
    logWarning('⚠️ Zbyt mało próbek do analizy! Wczytano tylko %d próbek.', successful_loads);
end

if isempty(X)
    logError('❌ Nie udało się wczytać żadnych danych!');
    error('Nie udało się wczytać żadnych danych!');
end

% Walidacja zgodności wymiarów macierzy
if size(X, 1) ~= size(Y, 1)
    logError('❌ Niezgodność wymiarów X(%dx%d) i Y(%dx%d)', ...
        size(X,1), size(X,2), size(Y,1), size(Y,2));
    error('Niezgodność wymiarów między macierzami X i Y!');
end

% Normalizacja cech (opcjonalna)
if normalize_features_flag && ~isempty(X)
    logInfo('⚖️ Normalizacja cech...');
    [X, norm_params] = normalizeFeatures(X);
    config.norm_params = norm_params;
else
    logInfo('🔧 Pomijanie normalizacji cech...');
end

% Zapis przetworzonychdanych do cache
saveProcessedData(X, Y, labels, successful_loads, failed_loads, config);

logInfo('📊 Podsumowanie: %d udanych, %d nieudanych wczytań', successful_loads, failed_loads);

end

% =========================================================================
% FUNKCJE POMOCNICZE
% =========================================================================

function result = yesno(flag)
% Konwertuje wartość logiczną na czytelny tekst
if flag
    result = 'tak';
else
    result = 'nie';
end
end