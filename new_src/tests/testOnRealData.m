function results = testOnRealData()
% TESTONREALDATA Test systemu na rzeczywistych danych głosowych
%
% Składnia:
%   results = testOnRealData()
%
% Ta funkcja testuje system ekstrakcji cech na rzeczywistych plikach audio
% znajdujących się w folderze data

% Inicjalizacja loggera
logInfo('🔍 Rozpoczynam test na rzeczywistych danych...');

% Zdefiniowanie katalogów z danymi
data_root = 'data';
results = struct();

% Struktura wynikowa dla statystyk
results.simple = struct();
results.complex = struct();
results.total_files = 0;
results.processed_files = 0;
results.feature_stats = struct();

% Dodanie definicji katalogu dla wyników
results_dir = 'test_results';
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

% Zdefiniowanie ścieżek dla plików wynikowych
output_means_image = fullfile(results_dir, 'feature_means_comparison.png');
output_simple_scatter = fullfile(results_dir, 'simple_features_scatter.png');
output_complex_scatter = fullfile(results_dir, 'complex_features_scatter.png');
output_results_file = fullfile(results_dir, 'real_data_results.mat');

try
    % Wybór losowej próbki z każdego katalogu dla testu
    data_categories = {'simple', 'complex'};
    
    % Przetwarzanie danych z każdej kategorii
    for cat_idx = 1:length(data_categories)
        category = data_categories{cat_idx};
        category_path = fullfile(data_root, category);
        
        if ~exist(category_path, 'dir')
            logWarning('⚠️ Katalog %s nie istnieje!', category_path);
            continue;
        end
        
        % Pobierz wszystkie podfoldery kategorii (np. 'a', 'e', 'i' dla simple)
        commands = dir(category_path);
        commands = commands([commands.isdir]);
        commands = commands(~ismember({commands.name}, {'.', '..'}));
        
        logInfo('📂 Znaleziono %d komend w kategorii %s', length(commands), category);
        
        % Inicjalizacja struktur do przechowywania wyników
        results.(category).commands = struct();
        results.(category).feature_matrices = {};
        results.(category).command_labels = {};
        
        % Przetwarzanie każdej komendy
        for cmd_idx = 1:length(commands)
            command_name = commands(cmd_idx).name;
            % Sanityzacja nazwy komendy
            sanitized_command_name = sanitizeName(command_name);
            command_path = fullfile(category_path, command_name);
            
            % Używamy sanityzowanej nazwy dla pola struktury
            results.(category).commands.(sanitized_command_name) = struct();
            results.(category).commands.(sanitized_command_name).samples = struct();
            
            % W zależności od kategorii, struktura podfolderów różni się
            if strcmp(category, 'simple')
                % Dla "simple" mamy tylko "normalnie" i "szybko"
                speeds = {'normalnie', 'szybko'};
                
                for speed_idx = 1:length(speeds)
                    speed = speeds{speed_idx};
                    speed_path = fullfile(command_path, speed);
                    
                    if ~exist(speed_path, 'dir')
                        continue;
                    end
                    
                    % Pobierz wszystkie pliki .wav
                    wav_files = dir(fullfile(speed_path, '*.wav'));
                    
                    % Wybierz losowy plik do testu
                    if ~isempty(wav_files)
                        % Wybierz losowy plik
                        random_idx = randi(length(wav_files));
                        test_file = fullfile(wav_files(random_idx).folder, wav_files(random_idx).name);
                        
                        % Przetwórz plik
                        logInfo('🔍 Przetwarzanie: %s / %s / %s', category, command_name, test_file);
                        [features, ~, processing_time] = processAudioFile(test_file);
                        
                        % Zapisz wyniki
                        results.(category).commands.(command_name).samples.(speed) = struct();
                        results.(category).commands.(command_name).samples.(speed).file = test_file;
                        results.(category).commands.(command_name).samples.(speed).features = features;
                        results.(category).commands.(command_name).samples.(speed).time = processing_time;
                        
                        % Dodaj do zbiorczych macierzy cech (dla późniejszej analizy)
                        results.(category).feature_matrices{end+1} = features;
                        results.(category).command_labels{end+1} = command_name;
                        
                        % Aktualizacja licznika przetworzonych plików
                        results.processed_files = results.processed_files + 1;
                    end
                    
                    % Aktualizacja licznika wszystkich plików
                    results.total_files = results.total_files + length(wav_files);
                end
            else
                % Dla "complex" mamy strukturę: obiekt/akcja/szybkość
                obj_dirs = dir(command_path);
                obj_dirs = obj_dirs([obj_dirs.isdir]);
                obj_dirs = obj_dirs(~ismember({obj_dirs.name}, {'.', '..'}));
                
                for obj_idx = 1:length(obj_dirs)
                    obj_name = obj_dirs(obj_idx).name;
                    % Sanityzacja nazwy obiektu
                    sanitized_obj_name = sanitizeName(obj_name);
                    obj_path = fullfile(command_path, obj_name);  % używamy oryginalnej nazwy dla ścieżki pliku
                    
                    % Pobierz katalogi akcji (np. "Włącz światło")
                    action_dirs = dir(obj_path);
                    action_dirs = action_dirs([action_dirs.isdir]);
                    action_dirs = action_dirs(~ismember({action_dirs.name}, {'.', '..'}));
                    
                    for action_idx = 1:length(action_dirs)
                        action_name = action_dirs(action_idx).name;
                        action_path = fullfile(obj_path, action_name);
                        
                        % Katalogi szybkości (normalnie/szybko)
                        speed_dirs = dir(action_path);
                        speed_dirs = speed_dirs([speed_dirs.isdir]);
                        speed_dirs = speed_dirs(~ismember({speed_dirs.name}, {'.', '..'}));
                        
                        for speed_idx = 1:length(speed_dirs)
                            speed = speed_dirs(speed_idx).name;
                            speed_path = fullfile(action_path, speed);
                            
                            % Pobierz wszystkie pliki .wav
                            wav_files = dir(fullfile(speed_path, '*.wav'));
                            
                            % Wybierz losowy plik do testu
                            if ~isempty(wav_files)
                                % Wybierz losowy plik
                                random_idx = randi(length(wav_files));
                                test_file = fullfile(wav_files(random_idx).folder, wav_files(random_idx).name);
                                
                                % Nazwa pełnej komendy
                                full_command = [sanitized_obj_name '_' action_name];
                                % Sanityzacja - zastąpienie znaków diakrytycznych i innych niedozwolonych
                                sanitized_command = sanitizeName(full_command);
                                
                                % Przetwórz plik
                                logInfo('🔍 Przetwarzanie: %s / %s / %s / %s', category, obj_name, action_name, test_file);
                                [features, ~, processing_time] = processAudioFile(test_file);
                                
                                % Zapisz wyniki
                                if ~isfield(results.(category).commands, sanitized_command)
                                    results.(category).commands.(sanitized_command) = struct();
                                    results.(category).commands.(sanitized_command).samples = struct();
                                end
                                
                                results.(category).commands.(sanitized_command).samples.(speed) = struct();
                                results.(category).commands.(sanitized_command).samples.(speed).file = test_file;
                                results.(category).commands.(sanitized_command).samples.(speed).features = features;
                                results.(category).commands.(sanitized_command).samples.(speed).time = processing_time;
                                
                                % Dodaj do zbiorczych macierzy cech
                                results.(category).feature_matrices{end+1} = features;
                                results.(category).command_labels{end+1} = sanitized_command;
                                
                                % Aktualizacja licznika przetworzonych plików
                                results.processed_files = results.processed_files + 1;
                            end
                            
                            % Aktualizacja licznika wszystkich plików
                            results.total_files = results.total_files + length(wav_files);
                        end
                    end
                end
            end
        end
        
        % Analizy statystyczne cech dla danej kategorii
        if ~isempty(results.(category).feature_matrices)
            % Łączenie wszystkich macierzy cech
            all_features = vertcat(results.(category).feature_matrices{:});
            
            % Statystyki
            results.(category).stats.mean = mean(all_features);
            results.(category).stats.std = std(all_features);
            results.(category).stats.min = min(all_features);
            results.(category).stats.max = max(all_features);
            
            logSuccess('✅ Podsumowanie dla kategorii %s: %d plików, %d cech', ...
                category, length(results.(category).feature_matrices), size(all_features, 2));
        end
    end
    
    % Wizualizacja wyników - proste wykresy dla każdej kategorii
    try
        % Wykres średnich wartości cech dla różnych kategorii
        figure('Name', 'Średnie wartości cech', 'NumberTitle', 'off');
        
        % Sprawdź czy mamy dane dla obu kategorii
        if isfield(results.simple, 'stats') && isfield(results.complex, 'stats')
            % Pobierz dane
            simple_means = results.simple.stats.mean;
            complex_means = results.complex.stats.mean;
            
            % Upewnij się, że mają tę samą długość
            min_length = min(length(simple_means), length(complex_means));
            simple_means = simple_means(1:min_length);
            complex_means = complex_means(1:min_length);
            
            % Wizualizacja
            bar([simple_means; complex_means]');
            title('Porównanie średnich wartości cech');
            legend({'Simple', 'Complex'});
            xlabel('Indeks cechy');
            ylabel('Średnia wartość');
            grid on;
            
            % Zapisz wykres
            saveas(gcf, output_means_image);
            logInfo('📊 Zapisano wykres porównania średnich wartości cech');
        end
        
        % Wizualizacja rozrzutu cech dla kategorii 'simple'
        if isfield(results.simple, 'feature_matrices') && ~isempty(results.simple.feature_matrices)
            figure('Name', 'Rozrzut cech - Simple', 'NumberTitle', 'off');
            
            % Łączenie wszystkich macierzy cech
            all_features = vertcat(results.simple.feature_matrices{:});
            
            % PCA do redukcji wymiarowości
            if size(all_features, 2) > 2
                [coeff, score] = pca(all_features);
                reduced_features = score(:, 1:2);  % Dwie główne składowe
            else
                reduced_features = all_features;
            end
            
            % Tworzenie kolorów dla różnych klas
            unique_labels = unique(results.simple.command_labels);
            colors = lines(length(unique_labels));
            
            % Inicjalizacja legendy
            legend_handles = [];
            legend_names = {};
            
            % Rysowanie punktów
            hold on;
            for i = 1:length(unique_labels)
                label = unique_labels{i};
                mask = strcmp(results.simple.command_labels, label);
                h = scatter(reduced_features(mask, 1), reduced_features(mask, 2), 50, colors(i, :), 'filled');
                legend_handles = [legend_handles, h];
                legend_names{end+1} = label;
            end
            
            title('Rozrzut cech (PCA) - Simple');
            xlabel('Pierwsza składowa główna');
            ylabel('Druga składowa główna');
            legend(legend_handles, legend_names);
            grid on;
            hold off;
            
            % Zapisz wykres
            saveas(gcf, output_simple_scatter);
            logInfo('📊 Zapisano wykres rozrzutu cech dla kategorii Simple');
        end
        
        % Wizualizacja rozrzutu cech dla kategorii 'complex'
        if isfield(results.complex, 'feature_matrices') && ~isempty(results.complex.feature_matrices)
            figure('Name', 'Rozrzut cech - Complex', 'NumberTitle', 'off');
            
            % Łączenie wszystkich macierzy cech
            all_features = vertcat(results.complex.feature_matrices{:});
            
            % PCA do redukcji wymiarowości
            if size(all_features, 2) > 2
                [coeff, score] = pca(all_features);
                reduced_features = score(:, 1:2);  % Dwie główne składowe
            else
                reduced_features = all_features;
            end
            
            % Tworzenie kolorów dla różnych klas
            unique_labels = unique(results.complex.command_labels);
            colors = lines(length(unique_labels));
            
            % Inicjalizacja legendy
            legend_handles = [];
            legend_names = {};
            
            % Rysowanie punktów
            hold on;
            for i = 1:length(unique_labels)
                if i > length(colors)
                    break;  % Zabezpieczenie przed zbyt wieloma klasami
                end
                
                label = unique_labels{i};
                mask = strcmp(results.complex.command_labels, label);
                h = scatter(reduced_features(mask, 1), reduced_features(mask, 2), 50, colors(i, :), 'filled');
                legend_handles = [legend_handles, h];
                legend_names{end+1} = label;
            end
            
            title('Rozrzut cech (PCA) - Complex');
            xlabel('Pierwsza składowa główna');
            ylabel('Druga składowa główna');
            if length(unique_labels) <= 10  % Legenda tylko jeśli nie ma zbyt wielu klas
                legend(legend_handles, legend_names);
            end
            grid on;
            hold off;
            
            % Zapisz wykres
            saveas(gcf, output_complex_scatter);
            logInfo('📊 Zapisano wykres rozrzutu cech dla kategorii Complex');
        end
        
        % Wizualizacja boxplotów dla wybranych cech
        try
            % Sprawdzenie czy mamy dane dla obu kategorii
            if isfield(results.simple, 'feature_matrices') && ~isempty(results.simple.feature_matrices) && ...
                    isfield(results.complex, 'feature_matrices') && ~isempty(results.complex.feature_matrices)
                
                % Wybierz podejście zależnie od liczby cech (dla większej czytelności)
                all_simple = vertcat(results.simple.feature_matrices{:});
                all_complex = vertcat(results.complex.feature_matrices{:});
                
                % Określenie liczby cech i wybór najbardziej istotnych
                num_features = size(all_simple, 2);
                
                if num_features > 10
                    % Jeśli mamy dużo cech, wybierz 8 najbardziej zróżnicowanych
                    simple_std = std(all_simple);
                    complex_std = std(all_complex);
                    combined_std = simple_std + complex_std;  % Suma odchyleń standardowych
                    [~, sorted_idx] = sort(combined_std, 'descend');
                    selected_features = sorted_idx(1:8);  % 8 najbardziej zróżnicowanych cech
                else
                    % Jeśli mamy mało cech, pokaż wszystkie
                    selected_features = 1:num_features;
                end
                
                % Tworzenie etykiet dla boxplotów
                if exist('feature_names', 'var') && ~isempty(feature_names)
                    feature_labels = feature_names(selected_features);
                else
                    feature_labels = cell(length(selected_features), 1);
                    for i = 1:length(selected_features)
                        feature_labels{i} = sprintf('Cecha %d', selected_features(i));
                    end
                end
                
                % Tworzenie danych do boxplotów - podejście grupowane (po kategorii)
                figure('Name', 'Boxploty cech', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 600]);
                
                % Przygotowanie danych do boxplotów (po 2 boxploty dla każdej cechy - simple i complex)
                boxplot_data = [];
                group_labels = [];
                
                for i = 1:length(selected_features)
                    feat_idx = selected_features(i);
                    % Dane dla kategorii simple
                    simple_values = all_simple(:, feat_idx);
                    % Dane dla kategorii complex
                    complex_values = all_complex(:, feat_idx);
                    
                    % Dodanie do zbiorczej macierzy
                    boxplot_data = [boxplot_data; simple_values; complex_values];
                    
                    % Etykiety grup
                    simple_labels = repmat({sprintf('%s-S', feature_labels{i})}, size(simple_values));
                    complex_labels = repmat({sprintf('%s-C', feature_labels{i})}, size(complex_values));
                    group_labels = [group_labels; simple_labels; complex_labels];
                end
                
                % Rysowanie boxplotów
                boxplot(boxplot_data, group_labels, 'GroupOrder', unique(group_labels));
                
                % Stylizacja wykresu
                title('Porównanie rozkładów wartości wybranych cech');
                ylabel('Wartość cechy');
                xlabel('Cechy (S-Simple, C-Complex)');
                grid on;
                set(gca, 'XTickLabelRotation', 45);  % Obróć etykiety dla lepszej czytelności
                
                % Zapisz wykres
                output_boxplot_image = fullfile(results_dir, 'feature_boxplots.png');
                saveas(gcf, output_boxplot_image);
                logInfo('📊 Zapisano boxploty wartości cech');
                
                % Alternatywna wizualizacja: boxploty dla każdej kategorii osobno
                % Boxploty dla kategorii simple - wszystkie komendy
                unique_simple_commands = unique(results.simple.command_labels);
                if length(unique_simple_commands) > 1 && length(unique_simple_commands) <= 10
                    figure('Name', 'Boxploty cech - Simple', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 600]);
                    
                    % Przygotowanie danych
                    boxplot_data = [];
                    group_labels = [];
                    
                    for cmd_idx = 1:length(unique_simple_commands)
                        cmd = unique_simple_commands{cmd_idx};
                        cmd_mask = strcmp(results.simple.command_labels, cmd);
                        cmd_features = vertcat(results.simple.feature_matrices{cmd_mask});
                        
                        % Wybierz tylko najbardziej znaczące cechy
                        cmd_features = cmd_features(:, selected_features);
                        
                        % Dodaj dane do zbiorczej macierzy
                        boxplot_data = [boxplot_data; cmd_features];
                        
                        % Etykiety
                        cmd_labels = repmat({cmd}, size(cmd_features, 1), 1);
                        group_labels = [group_labels; cmd_labels];
                    end
                    
                    % Rysowanie boxplotu
                    boxplot(boxplot_data, group_labels, 'GroupOrder', unique_simple_commands);
                    
                    % Stylizacja
                    title('Rozkład wartości cech dla różnych komend prostych');
                    ylabel('Wartość cechy');
                    xlabel('Komenda');
                    grid on;
                    
                    % Zapisz wykres
                    output_simple_boxplot = fullfile(results_dir, 'simple_commands_boxplots.png');
                    saveas(gcf, output_simple_boxplot);
                    logInfo('📊 Zapisano boxploty dla komend prostych');
                end
                
                % Boxploty dla poszczególnych cech - porównanie simple vs complex
                figure('Name', 'Boxploty poszczególnych cech', 'NumberTitle', 'off', 'Position', [100, 100, 1400, 800]);
                
                % Liczba wierszy i kolumn w siatce podwykresów
                num_plots = length(selected_features);
                grid_rows = ceil(sqrt(num_plots));
                grid_cols = ceil(num_plots / grid_rows);
                
                for i = 1:length(selected_features)
                    feat_idx = selected_features(i);
                    
                    % Utworzenie podwykresu
                    subplot(grid_rows, grid_cols, i);
                    
                    % Dane dla obu kategorii
                    simple_values = all_simple(:, feat_idx);
                    complex_values = all_complex(:, feat_idx);
                    
                    % Grupowanie danych
                    grouped_data = {simple_values, complex_values};
                    
                    % Rysowanie boxplotu dla tej cechy
                    boxplot(grouped_data, {'Simple', 'Complex'});
                    
                    % Stylizacja podwykresu
                    title(feature_labels{i});
                    ylabel('Wartość');
                    grid on;
                end
                
                % Wspólny tytuł
                sgtitle('Porównanie rozkładów poszczególnych cech między kategoriami');
                
                % Zapisz wykres
                output_features_boxplot = fullfile(results_dir, 'features_comparison_boxplots.png');
                saveas(gcf, output_features_boxplot);
                logInfo('📊 Zapisano boxploty porównawcze dla poszczególnych cech');
            end
            
        catch boxplot_error
            logError('❌ Błąd podczas tworzenia boxplotów: %s', boxplot_error.message);
        end
    catch viz_error
        logError('❌ Błąd podczas wizualizacji: %s', viz_error.message);
    end
    
    % Zapisanie wyników
    save(output_results_file, 'results');
    logSuccess('✅ Przetworzono %d/%d plików. Wyniki zapisane do %s', results.processed_files, results.total_files, output_results_file);
    
catch e
    logError('❌ Błąd podczas testu: %s', e.message);
    disp(e.stack);
end

% Zamknięcie pliku logu
closeLog();
end

% Funkcja pomocnicza do przetwarzania pojedynczego pliku audio
function [features, filtered_signal, processing_time] = processAudioFile(file_path)
% Wczytanie pliku audio
[signal, fs] = audioread(file_path);

% Konwersja do mono jeśli stereo
if size(signal, 2) > 1
    signal = mean(signal, 2);
end

% Pomiar czasu przetwarzania
tic;

% Dodanie niewielkiego szumu dla testu filtracji
noise_level = 0.05;
noisy_signal = signal + noise_level * randn(size(signal));

% Filtracja
try
    [filtered_signal, ~] = applyAdaptiveFilters(noisy_signal, signal);
catch filter_error
    logWarning('⚠️ Błąd w filtracji: %s. Używam oryginalnego sygnału.', filter_error.message);
    filtered_signal = signal;
end

% Ekstrakcja cech
try
    [features, ~] = extractFeatures(filtered_signal, fs);
catch extract_error
    logError('❌ Błąd w ekstrakcji cech: %s', extract_error.message);
    features = [];
end

% Zakończenie pomiaru czasu
processing_time = toc;
end

% Funkcja pomocnicza do sanityzacji nazw
function name = sanitizeName(text)
name = strrep(text, 'ś', 's');
name = strrep(name, 'Ś', 'S');
name = strrep(name, 'ą', 'a');
name = strrep(name, 'Ą', 'A');
name = strrep(name, 'ę', 'e');
name = strrep(name, 'Ę', 'E');
name = strrep(name, 'ć', 'c');
name = strrep(name, 'Ć', 'C');
name = strrep(name, 'ń', 'n');
name = strrep(name, 'Ń', 'N');
name = strrep(name, 'ó', 'o');
name = strrep(name, 'Ó', 'O');
name = strrep(name, 'ł', 'l');
name = strrep(name, 'Ł', 'L');
name = strrep(name, 'ż', 'z');
name = strrep(name, 'Ż', 'Z');
name = strrep(name, 'ź', 'z');
name = strrep(name, 'Ź', 'Z');
name = strrep(name, ' ', '_');
name = regexprep(name, '[^a-zA-Z0-9_]', '');
end