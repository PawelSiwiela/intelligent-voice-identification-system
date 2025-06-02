function features = fftFeatures(signal, fs)
% FFTFEATURES Ekstrakcja cech z transformaty Fouriera (FFT)
%
% Składnia:
%   features = fftFeatures(signal, fs)
%
% Argumenty:
%   signal - sygnał audio
%   fs - częstotliwość próbkowania
%
% Zwraca:
%   features - struktura zawierająca cechy FFT
%   - fft_range_1: Energia w paśmie niskim (100-200 Hz)
%   - fft_range_2: Energia w paśmie średnim (300-600 Hz)
%   - fft_range_3: Energia w paśmie wysokim (1000-2000 Hz)
%   - dominant_freq: Częstotliwość dominująca
%   - total_energy: Całkowita energia spektralna

% Inicjalizacja struktury wynikowej
features = struct();

try
    % Obliczenie FFT
    Y = fft(signal);
    N = length(Y);
    frequency = (0:N-1) * (fs/N);
    power_spectrum = abs(Y(1:floor(N/2)+1)).^2;
    freq_single = frequency(1:floor(N/2)+1);
    
    % Analiza energii w trzech różnych pasmach częstotliwości
    ranges = [
        100, 200;    % Niskie (fundamentalne)
        300, 600;    % Średnie (pierwsza formanta)
        1000, 2000   % Wysokie (druga formanta)
        ];
    
    for r = 1:3
        range_start = ranges(r, 1);
        range_end = ranges(r, 2);
        
        % Znalezienie indeksów w odpowiednim zakresie częstotliwości
        idx_range = (freq_single >= range_start) & (freq_single <= range_end);
        
        % Obliczenie energii w danym paśmie
        if any(idx_range)
            range_energy = sum(power_spectrum(idx_range));
        else
            range_energy = 0;
        end
        
        % Zapisanie cechy
        features.(sprintf('fft_range_%d', r)) = range_energy;
    end
    
    % Częstotliwość dominująca (odpowiadająca największemu pikowi)
    [~, peak_idx] = max(power_spectrum);
    features.dominant_freq = freq_single(peak_idx);
    
    % Całkowita energia spektralna
    features.total_energy = sum(power_spectrum);
    
catch
    % W przypadku błędu, inicjalizuj cechy zerami
    features.fft_range_1 = 0;
    features.fft_range_2 = 0;
    features.fft_range_3 = 0;
    features.dominant_freq = 0;
    features.total_energy = 0;
end

end