function features = spectralFeatures(signal, fs)
% SPECTRALFEATURES Ekstrakcja cech spektralnych sygnału audio
%
% Składnia:
%   features = spectralFeatures(signal, fs)
%
% Argumenty:
%   signal - sygnał audio
%   fs - częstotliwość próbkowania
%
% Zwraca:
%   features - struktura zawierająca cechy spektralne:
%     - centroid: Centroid spektralny - "jasność" dźwięku
%     - rolloff: Częstotliwość rolloff - punkt odcięcia 85% energii widma
%     - flatness: Płaskość spektralna - miara szumu vs ton
%     - flux: Strumień spektralny - miara zmian widma między ramkami
%     - bandwidth: Szerokość pasma spektralnego - rozpiętość pasma z energią

try
    % Obliczenie spektrogramu
    [S, F, T] = spectrogram(signal, hamming(256), 128, 512, fs);
    magnitude = abs(S);
    
    % Inicjalizacja struktury wynikowej
    features = struct();
    
    % 1. Centroid spektralny - "jasność" dźwięku
    weighted_sum = sum(magnitude .* F(:), 1);
    total_magnitude = sum(magnitude, 1);
    features.centroid = mean(weighted_sum ./ (total_magnitude + eps));
    
    % 2. Częstotliwość rolloff - 85% energii
    cumulative_energy = cumsum(magnitude, 1);
    total_energy = sum(magnitude, 1);
    rolloff_points = zeros(1, size(magnitude, 2));
    
    for frame = 1:size(magnitude, 2)
        threshold_energy = 0.85 * total_energy(frame);
        rolloff_idx = find(cumulative_energy(:, frame) >= threshold_energy, 1, 'first');
        if ~isempty(rolloff_idx)
            rolloff_points(frame) = F(rolloff_idx);
        end
    end
    features.rolloff = mean(rolloff_points);
    
    % 3. Płaskość spektralna (miara szumu vs ton)
    geometric_mean = exp(mean(log(total_magnitude + eps)));
    arithmetic_mean = mean(total_magnitude);
    features.flatness = geometric_mean / (arithmetic_mean + eps);
    
    % 4. Strumień spektralny (zmiana spektralna)
    if size(magnitude, 2) > 1
        spectral_diff = diff(magnitude, 1, 2);
        features.flux = mean(sum(spectral_diff.^2, 1));
    else
        features.flux = 0;
    end
    
    % 5. Szerokość pasma spektralnego
    centroid = features.centroid;
    weighted_variance = sum(magnitude .* (F(:) - centroid).^2, 1);
    features.bandwidth = mean(sqrt(weighted_variance ./ (total_magnitude + eps)));
    
catch e
    % W przypadku błędu, inicjalizuj cechy zerami
    features.centroid = 0;
    features.rolloff = 0;
    features.flatness = 0;
    features.flux = 0;
    features.bandwidth = 0;
end

end