function testResults = testFeatureExtraction()
% TESTFEATUREEXTRACTION Test funkcjonalności systemu ekstrakcji cech głosowych
%
% Składnia:
%   testResults = testFeatureExtraction()
%
% Zwraca:
%   testResults - struktura zawierająca wyniki testu

% Inicjalizacja loggera
logInfo('🧪 Rozpoczynam test ekstrakcji cech...');

% 1. KONFIGURACJA TESTU
try
    % Parametry testu
    test_file = 'test_audio.wav';
    noise_level = 0.1;
    
    % Sprawdzenie czy plik testowy istnieje
    if ~exist(test_file, 'file')
        % Jeśli nie ma pliku testowego, stwórz sztuczny sygnał testowy
        fs = 16000;
        duration = 3.0; % 3 sekundy
        t = 0:1/fs:duration-1/fs;
        
        % Utwórz prosty sygnał testowy (sinusoidy o różnych częstotliwościach)
        signal = sin(2*pi*440*t') + 0.5*sin(2*pi*880*t') + 0.25*sin(2*pi*1760*t');
        
        % Dodaj chwilowe uderzenie (symulacja spółgłoski)
        impact_pos = round(fs * 1.5); % w połowie sygnału
        impact_width = round(fs * 0.05); % 50ms
        impact_range = impact_pos:(impact_pos+impact_width);
        signal(impact_range) = signal(impact_range) + 0.8;
        
        % Normalizacja amplitudy
        signal = signal / max(abs(signal));
        
        % Zapisz sygnał testowy
        audiowrite(test_file, signal, fs);
        logInfo('📝 Utworzono syntetyczny plik testowy: %s', test_file);
    end
    
    % 2. WCZYTANIE PLIKU AUDIO
    [audio, fs] = audioread(test_file);
    
    % Konwersja do mono jeśli stereo
    if size(audio, 2) > 1
        audio = mean(audio, 2);
    end
    
    logInfo('📊 Wczytano plik: %s (fs=%dHz, długość=%.2fs)', ...
        test_file, fs, length(audio)/fs);
    
    % 3. TEST FILTRACJI ADAPTACYJNEJ
    try
        % Dodanie szumu testowego
        noisy_audio = audio + noise_level * randn(size(audio));
        
        % Filtracja adaptacyjna
        tic;
        [filtered_audio, mse] = applyAdaptiveFilters(noisy_audio, audio);
        filter_time = toc;
        
        logInfo('🔊 Filtracja: czas=%.3fs, MSE=%.6f', filter_time, mse);
        
        % Obliczenie stosunku sygnału do szumu (SNR)
        snr_before = 10 * log10(sum(audio.^2) / sum((noisy_audio - audio).^2));
        snr_after = 10 * log10(sum(audio.^2) / sum((filtered_audio - audio).^2));
        logSuccess('📈 Poprawa SNR: %.2f dB → %.2f dB (zysk: %.2f dB)', ...
            snr_before, snr_after, snr_after - snr_before);
        
        % Zapisanie plików audio do porównania
        audiowrite('test_noisy.wav', noisy_audio, fs);
        audiowrite('test_filtered.wav', filtered_audio, fs);
        
        % Zapis wyników do struktury
        testResults.filtering.success = true;
        testResults.filtering.time = filter_time;
        testResults.filtering.mse = mse;
        testResults.filtering.snr_before = snr_before;
        testResults.filtering.snr_after = snr_after;
        testResults.filtering.snr_gain = snr_after - snr_before;
    catch e
        logError('❌ Błąd w teście filtracji: %s', e.message);
        testResults.filtering.success = false;
        testResults.filtering.error = e.message;
    end
    
    % 4. TEST EKSTRAKCJI CECH
    try
        % Test poszczególnych ekstraktorów
        extractors = {'basicFeatures', 'envelopeFeatures', 'fftFeatures', ...
            'formantFeatures', 'mfccFeatures', 'spectralFeatures'};
        
        % Przygotowanie struktury do zapisania liczby cech
        testResults.extractors = struct();
        
        % Test każdego ekstraktora osobno
        for i = 1:length(extractors)
            extractor_name = extractors{i};
            
            try
                % Dynamiczne wywołanie ekstraktora
                if strcmp(extractor_name, 'mfccFeatures') || ...
                        strcmp(extractor_name, 'fftFeatures') || ...
                        strcmp(extractor_name, 'formantFeatures') || ...
                        strcmp(extractor_name, 'spectralFeatures')
                    % Ekstraktory wymagające częstotliwości próbkowania
                    features = feval(extractor_name, filtered_audio, fs);
                else
                    % Ekstraktory nie wymagające częstotliwości próbkowania
                    features = feval(extractor_name, filtered_audio);
                end
                
                % Liczba wyekstrahowanych cech
                feature_count = length(fieldnames(features));
                
                logSuccess('👍 %s: wyekstrahowano %d cech', ...
                    extractor_name, feature_count);
                
                % Zapisanie wyników do struktury
                testResults.extractors.(extractor_name).success = true;
                testResults.extractors.(extractor_name).feature_count = feature_count;
            catch e
                logError('❌ Błąd w ekstraktorze %s: %s', ...
                    extractor_name, e.message);
                
                testResults.extractors.(extractor_name).success = false;
                testResults.extractors.(extractor_name).error = e.message;
            end
        end
        
        % 5. TEST CAŁOŚCIOWEJ EKSTRAKCJI CECH
        tic;
        [features, feature_names] = extractFeatures(filtered_audio, fs);
        extraction_time = toc;
        
        logSuccess('🎯 Ekstrakcja cech: czas=%.3fs, liczba cech=%d', ...
            extraction_time, length(features));
        
        % Statystyki o cechach
        feature_mean = mean(features);
        feature_std = std(features);
        feature_ranges = [min(features); max(features)];
        
        % Zapisanie wyników do struktury
        testResults.extraction.success = true;
        testResults.extraction.time = extraction_time;
        testResults.extraction.feature_count = length(features);
        testResults.extraction.feature_names = feature_names;
        testResults.extraction.feature_mean = feature_mean;
        testResults.extraction.feature_std = feature_std;
        testResults.extraction.feature_range = feature_ranges;
    catch e
        logError('❌ Błąd w teście ekstrakcji cech: %s', e.message);
        testResults.extraction.success = false;
        testResults.extraction.error = e.message;
    end
    
    % 6. WIZUALIZACJA WYNIKÓW
    try
        % Wykresy sygnałów
        figure('Name', 'Porównanie sygnałów', 'NumberTitle', 'off');
        
        % Limit do 3 sekund dla lepszej widoczności
        plot_limit = min(length(audio), fs * 3);
        t = (0:plot_limit-1) / fs;
        
        subplot(3,1,1);
        plot(t, audio(1:plot_limit));
        title('Oryginalny sygnał');
        xlabel('Czas [s]');
        ylabel('Amplituda');
        
        subplot(3,1,2);
        plot(t, noisy_audio(1:plot_limit));
        title(sprintf('Sygnał z szumem (SNR = %.2f dB)', snr_before));
        xlabel('Czas [s]');
        ylabel('Amplituda');
        
        subplot(3,1,3);
        plot(t, filtered_audio(1:plot_limit));
        title(sprintf('Sygnał po filtracji (SNR = %.2f dB)', snr_after));
        xlabel('Czas [s]');
        ylabel('Amplituda');
        
        % Zapisanie wykresu
        saveas(gcf, 'test_signals_comparison.png');
        logInfo('📊 Zapisano wykres porównania sygnałów');
        
        % Wykres histogramu wartości cech
        if length(features) > 1
            figure('Name', 'Histogram cech', 'NumberTitle', 'off');
            histogram(features, 20, 'Normalization', 'probability');
            title('Rozkład wartości cech');
            xlabel('Wartość cechy');
            ylabel('Częstość występowania');
            
            % Zapisanie wykresu
            saveas(gcf, 'test_features_histogram.png');
            logInfo('📊 Zapisano histogram wartości cech');
        end
        
        testResults.visualization.success = true;
    catch e
        logError('❌ Błąd w wizualizacji: %s', e.message);
        testResults.visualization.success = false;
        testResults.visualization.error = e.message;
    end
    
    % 7. PODSUMOWANIE TESTU
    logSuccess('✅ Test zakończony pomyślnie!');
    
    % Zapisanie danych testowych
    save('test_results.mat', 'testResults');
    logInfo('💾 Wyniki testu zapisane do test_results.mat');
catch e
    logError('❌ Błąd ogólny testu: %s', e.message);
    disp(e.stack);
    testResults.success = false;
    testResults.error = e.message;
end

% Zamknięcie pliku logu
closeLog();

end