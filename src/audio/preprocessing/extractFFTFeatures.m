function fft_features = extractFFTFeatures(signal, fs)
% =========================================================================
% CECHY FFT - ROZSZERZONE DO 6 CECH
% =========================================================================

try
    fft_features = struct();
    
    Y = fft(signal);
    N = length(Y);
    frequency = (0:N-1) * (fs/N);
    power_spectrum = abs(Y(1:floor(N/2)+1)).^2;
    freq_single = frequency(1:floor(N/2)+1);
    
    % ORYGINALNYCH 3 ZAKRESY
    ranges = [
        100, 200;    % Niskie (fundamentalne)
        300, 600;    % Średnie (pierwsza formanta)
        1000, 2000   % Wysokie (druga formanta)
        ];
    
    for r = 1:3
        range_start = ranges(r, 1);
        range_end = ranges(r, 2);
        
        idx_range = (freq_single >= range_start) & (freq_single <= range_end);
        
        if any(idx_range)
            range_energy = sum(power_spectrum(idx_range));
        else
            range_energy = 0;
        end
        
        fft_features.(sprintf('fft_range_%d', r)) = range_energy;
    end
    
    % NOWE 3 CECHY GLOBALNE
    [~, peak_idx] = max(power_spectrum);
    fft_features.dominant_freq = freq_single(peak_idx);          % Częstotliwość dominująca
    fft_features.spectral_centroid = sum(freq_single .* power_spectrum') / sum(power_spectrum); % Centroid spektralny
    fft_features.total_energy = sum(power_spectrum);             % Całkowita energia spektralna
    
    logDebug('✅ Cechy FFT: 6 cech');
    
catch ME
    logWarning('⚠️ Błąd cech FFT: %s', ME.message);
    fft_features = struct();
    fft_features.fft_range_1 = 0; fft_features.fft_range_2 = 0; fft_features.fft_range_3 = 0;
    fft_features.dominant_freq = 0; fft_features.spectral_centroid = 0; fft_features.total_energy = 0;
end

end