function basic_features = extractBasicFeatures(signal)
% =========================================================================
% PODSTAWOWE CECHY STATYSTYCZNE - ROZSZERZONE DO 8 CECH
% =========================================================================

try
    basic_features = struct();
    
    % ORYGINALNYCH 5 CECH
    basic_features.mean = mean(signal);
    basic_features.std = std(signal);
    basic_features.rms = sqrt(mean(signal.^2));
    basic_features.range = max(signal) - min(signal);
    
    zero_crossings = sum(abs(diff(sign(signal)))) / 2;
    if length(signal) > 1
        basic_features.zero_crossing_rate = zero_crossings / (length(signal) - 1);
    else
        basic_features.zero_crossing_rate = 0;
    end
    
    % NOWE 3 CECHY
    basic_features.variance = var(signal);           % Wariancja
    basic_features.skewness = skewness(signal);      % Asymetria rozkładu
    basic_features.kurtosis = kurtosis(signal);      % Kurtoza (spiczastość)
    
    logDebug('✅ Podstawowe cechy: 8 cech');
    
catch ME
    logWarning('⚠️ Błąd podstawowych cech: %s', ME.message);
    basic_features = struct();
    basic_features.mean = 0; basic_features.std = 0; basic_features.rms = 0;
    basic_features.range = 0; basic_features.zero_crossing_rate = 0;
    basic_features.variance = 0; basic_features.skewness = 0; basic_features.kurtosis = 0;
end

end