function results = testBoxplots()
% TESTBOXPLOTS Prosty test tworzenia boxplotów dla cech głosowych
%
% Ta funkcja wczytuje pojedynczą próbkę audio, ekstrahuje cechy
% i tworzy szczegółowe wizualizacje tych cech.

logInfo('📊 Rozpoczynam test ekstrakcji cech dla pojedynczej próbki...');

% Katalog wyników
results_dir = 'test_results';
if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

try
    % Struktura na wyniki
    results = struct();
    global_feature_names = {};
    
    % Wczytaj pojedynczą próbkę - wybierzmy pierwszą próbkę z kategorii "simple"
    test_file = 'data/simple/a/normalnie/Dźwięk 1.wav';
    
    if ~exist(test_file, 'file')
        % Jeśli nie ma konkretnego pliku, znajdźmy pierwszy dostępny
        logWarning('⚠️ Nie znaleziono pliku %s, szukam alternatywnego pliku...', test_file);
        
        % Przeszukaj katalog "simple"
        simple_dir = 'data/simple';
        if exist(simple_dir, 'dir')
            cmd_dirs = dir(simple_dir);
            cmd_dirs = cmd_dirs([cmd_dirs.isdir]);
            cmd_dirs = cmd_dirs(~ismember({cmd_dirs.name}, {'.', '..'}));
            
            for cmd_idx = 1:length(cmd_dirs)
                cmd_path = fullfile(simple_dir, cmd_dirs(cmd_idx).name, 'normalnie');
                if exist(cmd_path, 'dir')
                    wav_files = dir(fullfile(cmd_path, '*.wav'));
                    if ~isempty(wav_files)
                        test_file = fullfile(wav_files(1).folder, wav_files(1).name);
                        break;
                    end
                end
            end
        end
    end
    
    if ~exist(test_file, 'file')
        error('Nie znaleziono żadnego pliku audio do testu!');
    end
    
    % Wczytanie pliku
    logInfo('🔍 Wczytywanie pliku: %s', test_file);
    [signal, fs] = audioread(test_file);
    
    % Konwersja do mono
    if size(signal, 2) > 1
        signal = mean(signal, 2);
    end
    
    % Podstawowe informacje o sygnale
    logInfo('📊 Częstotliwość próbkowania: %d Hz, Długość: %.2f s', fs, length(signal)/fs);
    
    % Dodanie szumu dla testowania filtracji
    noise_level = 0.05;
    noisy_signal = signal + noise_level * randn(size(signal));
    
    % Filtracja sygnału
    logInfo('🔄 Rozpoczynam filtrację adaptacyjną...');
    [filtered_signal, mse] = applyAdaptiveFilters(noisy_signal, signal);
    
    % Obliczenie SNR przed i po filtracji
    snr_before = 10 * log10(sum(signal.^2) / sum((noisy_signal - signal).^2));
    snr_after = 10 * log10(sum(signal.^2) / sum((filtered_signal - signal).^2));
    logInfo('📈 SNR przed filtracją: %.2f dB, po filtracji: %.2f dB', snr_before, snr_after);
    
    % Wizualizacja sygnałów
    figure('Name', 'Porównanie sygnałów', 'NumberTitle', 'off', 'Position', [100, 100, 1200, 800]);
    
    % Oryginalny sygnał
    subplot(3,1,1);
    plot((1:length(signal))/fs, signal);
    title('Oryginalny sygnał');
    xlabel('Czas [s]');
    ylabel('Amplituda');
    grid on;
    
    % Zaszumiony sygnał
    subplot(3,1,2);
    plot((1:length(noisy_signal))/fs, noisy_signal);
    title(sprintf('Zaszumiony sygnał (SNR = %.2f dB)', snr_before));
    xlabel('Czas [s]');
    ylabel('Amplituda');
    grid on;
    
    % Przefiltrowany sygnał
    subplot(3,1,3);
    plot((1:length(filtered_signal))/fs, filtered_signal);
    title(sprintf('Przefiltrowany sygnał (SNR = %.2f dB)', snr_after));
    xlabel('Czas [s]');
    ylabel('Amplituda');
    grid on;
    
    % Zapisz wykres
    saveas(gcf, fullfile(results_dir, 'single_sample_signals.png'));
    logInfo('📊 Zapisano porównanie sygnałów');
    
    % Ekstrakcja cech
    logInfo('🔄 Rozpoczynam ekstrakcję cech...');
    [features, feature_names] = extractFeatures(filtered_signal, fs);
    
    % Zapisz nazwy cech
    if ~isempty(feature_names)
        global_feature_names = feature_names;
    end
    
    logInfo('✅ Wyekstrahowano %d cech', length(features));
    
    % Wizualizacja wartości cech
    figure('Name', 'Wartości cech', 'NumberTitle', 'off', 'Position', [100, 100, 1400, 600]);
    
    % Wykres słupkowy wartości cech
    bar(features);
    title('Wartości cech dla pojedynczej próbki');
    xlabel('Indeks cechy');
    ylabel('Wartość');
    grid on;
    
    % Etykiety dla cech, jeśli są dostępne
    if ~isempty(global_feature_names) && length(global_feature_names) == length(features)
        xticks(1:length(features));
        
        % Jeśli jest zbyt wiele cech, pokazuj co n-tą etykietę
        if length(features) > 20
            step = ceil(length(features) / 20);
            visible_ticks = 1:step:length(features);
            xticklabels(repmat({''}, 1, length(features)));
            set(gca, 'XTick', visible_ticks);
            set(gca, 'XTickLabel', global_feature_names(visible_ticks));
        else
            set(gca, 'XTickLabel', global_feature_names);
        end
        set(gca, 'XTickLabelRotation', 45);
    end
    
    % Zapisz wykres
    saveas(gcf, fullfile(results_dir, 'single_sample_feature_values.png'));
    logInfo('📊 Zapisano wykres wartości cech');
    
    % Normalizacja cech do zakresu [0,1]
    min_val = min(features);
    max_val = max(features);
    range = max_val - min_val;
    if range == 0
        range = 1;  % Uniknij dzielenia przez zero
    end
    normalized_features = (features - min_val) / range;
    
    % Wizualizacja znormalizowanych cech
    figure('Name', 'Znormalizowane cechy', 'NumberTitle', 'off', 'Position', [100, 100, 1400, 600]);
    bar(normalized_features);
    title('Znormalizowane wartości cech dla pojedynczej próbki');
    xlabel('Indeks cechy');
    ylabel('Znormalizowana wartość');
    ylim([-0.1, 1.1]);
    grid on;
    
    % Etykiety dla cech, jeśli są dostępne
    if ~isempty(global_feature_names) && length(global_feature_names) == length(features)
        xticks(1:length(features));
        
        % Jeśli jest zbyt wiele cech, pokazuj co n-tą etykietę
        if length(features) > 20
            step = ceil(length(features) / 20);
            visible_ticks = 1:step:length(features);
            xticklabels(repmat({''}, 1, length(features)));
            set(gca, 'XTick', visible_ticks);
            set(gca, 'XTickLabel', global_feature_names(visible_ticks));
        else
            set(gca, 'XTickLabel', global_feature_names);
        end
        set(gca, 'XTickLabelRotation', 45);
    end
    
    % Zapisz wykres
    saveas(gcf, fullfile(results_dir, 'single_sample_normalized_feature_values.png'));
    logInfo('📊 Zapisano wykres znormalizowanych wartości cech');
    
    % Grupowanie cech według typu/domeny
    if ~isempty(global_feature_names)
        % Przykładowa klasyfikacja cech według nazwy
        time_domain_idx = contains(lower(global_feature_names), {'time', 'zcr', 'energy'});
        freq_domain_idx = contains(lower(global_feature_names), {'spectral', 'freq', 'fft'});
        mfcc_idx = contains(lower(global_feature_names), 'mfcc');
        other_idx = ~(time_domain_idx | freq_domain_idx | mfcc_idx);
        
        % Wizualizacja cech według grup
        figure('Name', 'Cechy według grup', 'NumberTitle', 'off', 'Position', [100, 100, 1400, 800]);
        
        % Przygotowanie danych dla grup
        group_data = [];
        group_names = {};
        
        % Dodaj cechy dziedziny czasu jeśli istnieją
        if any(time_domain_idx)
            group_data = [group_data; normalized_features(time_domain_idx)'];  % Dodano transpozycję (')
            group_names = [group_names; repmat({'Time Domain'}, sum(time_domain_idx), 1)];
        end
        
        % Dodaj cechy dziedziny częstotliwości jeśli istnieją
        if any(freq_domain_idx)
            group_data = [group_data; normalized_features(freq_domain_idx)'];  % Dodano transpozycję (')
            group_names = [group_names; repmat({'Frequency Domain'}, sum(freq_domain_idx), 1)];
        end
        
        % Dodaj cechy MFCC jeśli istnieją
        if any(mfcc_idx)
            group_data = [group_data; normalized_features(mfcc_idx)'];  % Dodano transpozycję (')
            group_names = [group_names; repmat({'MFCC'}, sum(mfcc_idx), 1)];
        end
        
        % Dodaj pozostałe cechy
        if any(other_idx)
            group_data = [group_data; normalized_features(other_idx)'];  % Dodano transpozycję (')
            group_names = [group_names; repmat({'Other'}, sum(other_idx), 1)];
        end
        
        % Rysuj boxplot według grup
        boxplot(group_data, group_names, 'GroupOrder', unique(group_names));
        title('Rozkład wartości cech według typu');
        xlabel('Domena');
        ylabel('Znormalizowana wartość');
        ylim([-0.1, 1.1]);
        grid on;
        
        % Zapisz wykres
        saveas(gcf, fullfile(results_dir, 'single_sample_feature_domains.png'));
        logInfo('📊 Zapisano rozkład cech według domen');
        
        % Wizualizacja szczegółowa dla każdej grupy cech
        figure('Name', 'Szczegółowe cechy według grup', 'NumberTitle', 'off', 'Position', [100, 100, 1400, 900]);
        
        % Liczba grup do wizualizacji
        num_groups = sum([any(time_domain_idx), any(freq_domain_idx), any(mfcc_idx), any(other_idx)]);
        current_plot = 1;
        
        % Cechy dziedziny czasu
        if any(time_domain_idx)
            subplot(num_groups, 1, current_plot);
            bar(normalized_features(time_domain_idx));
            title('Cechy dziedziny czasu');
            if sum(time_domain_idx) <= 20
                xticks(1:sum(time_domain_idx));
                xticklabels(global_feature_names(time_domain_idx));
                set(gca, 'XTickLabelRotation', 45);
            end
            ylabel('Wartość');
            ylim([0, 1]);
            grid on;
            current_plot = current_plot + 1;
        end
        
        % Cechy dziedziny częstotliwości
        if any(freq_domain_idx)
            subplot(num_groups, 1, current_plot);
            bar(normalized_features(freq_domain_idx));
            title('Cechy dziedziny częstotliwości');
            if sum(freq_domain_idx) <= 20
                xticks(1:sum(freq_domain_idx));
                xticklabels(global_feature_names(freq_domain_idx));
                set(gca, 'XTickLabelRotation', 45);
            end
            ylabel('Wartość');
            ylim([0, 1]);
            grid on;
            current_plot = current_plot + 1;
        end
        
        % Cechy MFCC
        if any(mfcc_idx)
            subplot(num_groups, 1, current_plot);
            bar(normalized_features(mfcc_idx));
            title('Współczynniki MFCC');
            if sum(mfcc_idx) <= 20
                xticks(1:sum(mfcc_idx));
                xticklabels(global_feature_names(mfcc_idx));
                set(gca, 'XTickLabelRotation', 45);
            end
            ylabel('Wartość');
            ylim([0, 1]);
            grid on;
            current_plot = current_plot + 1;
        end
        
        % Pozostałe cechy
        if any(other_idx)
            subplot(num_groups, 1, current_plot);
            bar(normalized_features(other_idx));
            title('Pozostałe cechy');
            if sum(other_idx) <= 20
                xticks(1:sum(other_idx));
                xticklabels(global_feature_names(other_idx));
                set(gca, 'XTickLabelRotation', 45);
            end
            ylabel('Wartość');
            ylim([0, 1]);
            grid on;
        end
        
        % Zapisz wykres
        saveas(gcf, fullfile(results_dir, 'single_sample_detailed_features.png'));
        logInfo('📊 Zapisano szczegółowe wykresy cech według typów');
    end
    
    % Zapisz wyniki
    results.file = test_file;
    results.fs = fs;
    results.signal_length = length(signal);
    results.signal_duration = length(signal)/fs;
    results.features = features;
    results.normalized_features = normalized_features;
    results.snr_before = snr_before;
    results.snr_after = snr_after;
    results.snr_gain = snr_after - snr_before;
    
    if ~isempty(global_feature_names)
        results.feature_names = global_feature_names;
    end
    
    save(fullfile(results_dir, 'single_sample_results.mat'), 'results');
    logSuccess('✅ Test zakończony. Wyniki zapisane do %s', fullfile(results_dir, 'single_sample_results.mat'));
    
catch e
    logError('❌ Błąd podczas testu: %s', e.message);
    disp(e.stack);
end

closeLog();

end

% Funkcja pomocnicza do normalizacji cech
function [normalized_data, params] = normalizeFeatures(data)
% Oblicz min i max dla każdej cechy
min_vals = min(data, [], 1);
max_vals = max(data, [], 1);

% Unikaj dzielenia przez zero (gdy min==max)
range = max_vals - min_vals;
range(range == 0) = 1; % Dla stałych cech, ustaw zakres na 1 aby uniknąć dzielenia przez zero

% Normalizacja do zakresu [0,1]
normalized_data = (data - repmat(min_vals, size(data, 1), 1)) ./ repmat(range, size(data, 1), 1);

% Parametry normalizacji (do późniejszego odwrócenia normalizacji)
params.min = min_vals;
params.max = max_vals;
params.range = range;
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