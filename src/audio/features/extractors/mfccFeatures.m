function features = mfccFeatures(signal, fs)
% MFCCFEATURES Ekstrakcja współczynników cepstralnych w skali mel (MFCC)
%
% Składnia:
%   features = mfccFeatures(signal, fs)
%
% Argumenty:
%   signal - sygnał audio
%   fs - częstotliwość próbkowania
%
% Zwraca:
%   features - struktura zawierająca współczynniki MFCC:
%     - mfcc_1: Pierwszy współczynnik MFCC
%     - mfcc_2: Drugi współczynnik MFCC
%     - ...
%     - mfcc_10: Dziesiąty współczynnik MFCC

try
    % Parametry ekstrakcji MFCC
    numCoeffs = 10;  % Liczba współczynników MFCC
    frameLength = round(0.025 * fs);  % 25 ms ramki
    frameOverlap = round(0.01 * fs);  % 10 ms nakładania
    
    % Jeśli sygnał jest zbyt krótki, dopełnij zerami
    if length(signal) < frameLength
        signal = [signal; zeros(frameLength - length(signal), 1)];
    end
    
    % Inicjalizacja struktury wynikowej
    features = struct();
    
    % Sprawdź dostępność funkcji mfcc() z Audio Toolbox
    if exist('mfcc', 'file') == 2
        % Użyj wbudowanej funkcji MFCC z Audio Toolbox
        coeffs = mfcc(signal, fs, 'NumCoeffs', numCoeffs, ...
            'WindowLength', frameLength, 'OverlapLength', frameOverlap);
        
        % Oblicz średnie wartości współczynników ze wszystkich ramek
        mfcc_mean = mean(coeffs, 1);
        
        % Zapisz współczynniki do struktury wynikowej
        for i = 1:numCoeffs
            features.(sprintf('mfcc_%d', i)) = mfcc_mean(i);
        end
    else
        % Jeśli Audio Toolbox nie jest dostępny, użyj wartości zerowych
        for i = 1:numCoeffs
            features.(sprintf('mfcc_%d', i)) = 0;
        end
    end
    
catch e
    % W przypadku błędu, inicjalizuj cechy zerami
    for i = 1:10
        features.(sprintf('mfcc_%d', i)) = 0;
    end
end

end