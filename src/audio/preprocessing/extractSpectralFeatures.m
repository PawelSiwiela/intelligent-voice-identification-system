function spectral_features = extractSpectralFeatures(signal, fs)
% =========================================================================
% CECHY SPEKTRALNE - ROZSZERZONE DO 6 CECH
% =========================================================================

try
    % Obliczenie spektrogramu
    [S, F, T] = spectrogram(signal, hamming(256), 128, 512, fs);
    magnitude = abs(S);
    
    spectral_features = struct();
    
    % ORYGINALNYCH 3 CECHY
    
    % 1. SPECTRAL CENTROID - "jasność" dźwięku
    weighted_sum = sum(magnitude .* F(:), 1);
    total_magnitude = sum(magnitude, 1);
    spectral_features.spectral_centroid = mean(weighted_sum ./ (total_magnitude + eps));
    
    % 2. SPECTRAL ROLLOFF - 85% energii
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
    spectral_features.spectral_rolloff = mean(rolloff_points);
    
    % 3. ZERO CROSSING RATE
    sign_changes = abs(diff(sign(signal)));
    spectral_features.zero_crossing_rate = sum(sign_changes) / (2 * length(signal));
    
    % NOWE 3 CECHY
    
    % Spectral flatness (miara szumu vs ton)
    geometric_mean = exp(mean(log(total_magnitude + eps)));
    arithmetic_mean = mean(total_magnitude);
    spectral_features.spectral_flatness = geometric_mean / (arithmetic_mean + eps);
    
    % Spectral flux (zmiana spektralna)
    if size(magnitude, 2) > 1
        spectral_diff = diff(magnitude, 1, 2);
        spectral_features.spectral_flux = mean(sum(spectral_diff.^2, 1));
    else
        spectral_features.spectral_flux = 0;
    end
    
    % Spectral bandwidth (szerokość pasma)
    centroid = spectral_features.spectral_centroid;
    weighted_variance = sum(magnitude .* (F(:) - centroid).^2, 1);
    spectral_features.spectral_bandwidth = mean(sqrt(weighted_variance ./ (total_magnitude + eps)));
    
    logDebug('✅ Cechy spektralne: 6 cech');
    
catch ME
    logWarning('Błąd cech spektralnych: %s', ME.message);
    spectral_features = struct();
    spectral_features.spectral_centroid = 0; spectral_features.spectral_rolloff = 0;
    spectral_features.zero_crossing_rate = 0; spectral_features.spectral_flatness = 0;
    spectral_features.spectral_flux = 0; spectral_features.spectral_bandwidth = 0;
end

end