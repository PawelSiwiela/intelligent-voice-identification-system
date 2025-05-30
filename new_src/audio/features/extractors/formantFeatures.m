function features = formantFeatures(signal, fs)
% FORMANTFEATURES Ekstrakcja cech formantów z sygnału audio
%
% Składnia:
%   features = formantFeatures(signal, fs)
%
% Argumenty:
%   signal - sygnał audio
%   fs - częstotliwość próbkowania
%
% Zwraca:
%   features - struktura zawierająca cechy formantów:
%     - f1: Pierwsza formanta - najniższa rezonansowa częstotliwość sygnału mowy
%     - f2: Druga formanta - drugi rezonans, zależny od położenia języka
%     - f3: Trzecia formanta - pomocnicza w złożonych analizach fonetycznych
%     - f2_f1_ratio: Stosunek F2/F1 - wskaźnik relacyjny dla samogłosek
%     - formant_bandwidth: Szerokość pasma formantów - miara stabilności rezonansu

try
    % Pre-emphasis - wzmocnienie wysokich częstotliwości
    pre_emphasized = filter([1 -0.97], 1, signal);
    
    % Inicjalizacja struktury wynikowej
    features = struct();
    
    % Uproszczona analiza LPC tylko dla całego sygnału
    if length(pre_emphasized) > 12
        % Analiza LPC (Linear Predictive Coding)
        [a, ~] = lpc(pre_emphasized, 12);
        
        % Znalezienie pierwiastków wielomianu LPC
        roots_lpc = roots(a);
        
        % Wybór tylko pierwiastków z dodatnią częścią urojoną (jedna połowa okręgu zespolonego)
        complex_roots = roots_lpc(imag(roots_lpc) > 0);
        
        % Konwersja z kątów biegunowych na częstotliwości
        frequencies = abs(angle(complex_roots)) * fs / (2 * pi);
        
        % Filtracja i sortowanie częstotliwości formantów (100Hz - 4000Hz to typowy zakres)
        frequencies = sort(frequencies(frequencies > 100 & frequencies < 4000));
        
        % 1. Pierwsza formanta (F1)
        if length(frequencies) >= 1
            features.f1 = frequencies(1);
        else
            features.f1 = 500;  % Wartość domyślna, jeśli nie znaleziono
        end
        
        % 2. Druga formanta (F2)
        if length(frequencies) >= 2
            features.f2 = frequencies(2);
        else
            features.f2 = 1500;  % Wartość domyślna
        end
        
        % 3. Stosunek F2/F1 - kluczowy dla samogłosek
        features.f2_f1_ratio = features.f2 / (features.f1 + eps);
        
        % 4. Trzecia formanta (F3)
        if length(frequencies) >= 3
            features.f3 = frequencies(3);
        else
            features.f3 = 2500;  % Wartość domyślna
        end
        
        % 5. Szerokość pasma formantów (przybliżona)
        if length(frequencies) >= 2
            features.formant_bandwidth = mean(diff(frequencies(1:min(3, length(frequencies)))));
        else
            features.formant_bandwidth = 500;  % Wartość domyślna
        end
    else
        % Dla zbyt krótkich sygnałów, użyj wartości domyślnych
        features.f1 = 500;
        features.f2 = 1500;
        features.f2_f1_ratio = 3;
        features.f3 = 2500;
        features.formant_bandwidth = 500;
    end
    
catch e
    % W przypadku błędu, inicjalizuj cechy wartościami domyślnymi
    features.f1 = 500;
    features.f2 = 1500;
    features.f2_f1_ratio = 3;
    features.f3 = 2500;
    features.formant_bandwidth = 500;
end

end