function formant_features = extractFormantFeatures(signal, fs)
% =========================================================================
% FORMANTY - ROZSZERZONE DO 5 CECH
% =========================================================================

try
    % Pre-emphasis
    pre_emphasized = filter([1 -0.97], 1, signal);
    
    formant_features = struct();
    
    % Uproszczona analiza LPC tylko dla całego sygnału
    if length(pre_emphasized) > 12
        [a, ~] = lpc(pre_emphasized, 12);
        roots_lpc = roots(a);
        complex_roots = roots_lpc(imag(roots_lpc) > 0);
        frequencies = abs(angle(complex_roots)) * fs / (2 * pi);
        frequencies = sort(frequencies(frequencies > 100 & frequencies < 4000));
        
        % ORYGINALNYCH 3 CECHY
        if length(frequencies) >= 1
            formant_features.f1 = frequencies(1);  % Pierwsza formanta
        else
            formant_features.f1 = 500;
        end
        
        if length(frequencies) >= 2
            formant_features.f2 = frequencies(2);  % Druga formanta
        else
            formant_features.f2 = 1500;
        end
        
        % Stosunek F2/F1 - kluczowy dla samogłosek
        formant_features.f2_f1_ratio = formant_features.f2 / (formant_features.f1 + eps);
        
        % NOWE 2 CECHY
        if length(frequencies) >= 3
            formant_features.f3 = frequencies(3);           % Trzecia formanta
        else
            formant_features.f3 = 2500;
        end
        
        % Szerokość pasma formantów (przybliżona)
        formant_features.formant_bandwidth = mean(diff(frequencies(1:min(3, length(frequencies)))));
        
    else
        formant_features.f1 = 500;
        formant_features.f2 = 1500;
        formant_features.f2_f1_ratio = 3;
        formant_features.f3 = 2500;
        formant_features.formant_bandwidth = 500;
    end
    
    logDebug('✅ Cechy formantów: 5 cech');
    
catch ME
    logWarning('Błąd formantów: %s', ME.message);
    formant_features = struct();
    formant_features.f1 = 500;
    formant_features.f2 = 1500;
    formant_features.f2_f1_ratio = 3;
    formant_features.f3 = 2500;
    formant_features.formant_bandwidth = 500;
end

end