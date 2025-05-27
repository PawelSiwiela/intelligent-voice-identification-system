function envelope_features = extractEnvelopeFeatures(signal, envelope_window)
% =========================================================================
% CECHY OBWIEDNI - ROZSZERZONE DO 7 CECH
% =========================================================================

if nargin < 2
    envelope_window = 200;
end

try
    envelope_features = struct();
    
    % Sprawdzenie długości sygnału
    if length(signal) < envelope_window
        envelope_window = max(10, floor(length(signal)/2));
    end
    
    % Obliczenie obwiedni
    [upper_env, lower_env] = envelope(signal, envelope_window, 'peak');
    
    % ORYGINALNYCH 4 CECHY
    envelope_features.upper_mean = mean(upper_env);     % Średnia górnej obwiedni
    envelope_features.upper_std = std(upper_env);       % Zmienność górnej obwiedni
    envelope_features.lower_mean = mean(lower_env);     % Średnia dolnej obwiedni
    envelope_features.env_diff_mean = mean(upper_env - lower_env); % Różnica obwiedni
    
    % NOWE 3 CECHY
    envelope_features.lower_std = std(lower_env);                    % Zmienność dolnej obwiedni
    envelope_features.env_ratio = mean(upper_env ./ (abs(lower_env) + eps)); % Stosunek obwiedni
    envelope_features.env_range = mean(max(upper_env) - min(lower_env)); % Zakres obwiedni
    
    logDebug('✅ Cechy obwiedni: 7 cech');
    
catch ME
    logWarning('⚠️ Błąd cech obwiedni: %s', ME.message);
    envelope_features = struct();
    envelope_features.upper_mean = 0; envelope_features.upper_std = 0;
    envelope_features.lower_mean = 0; envelope_features.env_diff_mean = 0;
    envelope_features.lower_std = 0; envelope_features.env_ratio = 0;
    envelope_features.env_range = 0;
end

end