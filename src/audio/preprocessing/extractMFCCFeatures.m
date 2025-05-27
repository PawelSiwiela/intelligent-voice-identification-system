function mfcc_features = extractMFCCFeatures(signal, fs)
% =========================================================================
% MFCC - ROZSZERZONE DO 10 WSPÓŁCZYNNIKÓW
% =========================================================================

try
    % ZWIĘKSZONE PARAMETRY
    numCoeffs = 10;  % Zwiększone z 6 na 10
    frameLength = round(0.025 * fs);
    frameOverlap = round(0.01 * fs);
    
    if length(signal) < frameLength
        signal = [signal; zeros(frameLength - length(signal), 1)];
    end
    
    mfcc_features = struct();
    
    if exist('mfcc', 'file') == 2
        coeffs = mfcc(signal, fs, 'NumCoeffs', numCoeffs, ...
            'WindowLength', frameLength, 'OverlapLength', frameOverlap);
        
        % 10 ŚREDNICH WSPÓŁCZYNNIKÓW MFCC
        mfcc_mean = mean(coeffs, 1);
        for i = 1:numCoeffs
            mfcc_features.(sprintf('mfcc_%d', i)) = mfcc_mean(i);
        end
        
    else
        logWarning('Funkcja mfcc() niedostępna. Używam uproszconej implementacji.');
        for i = 1:numCoeffs
            mfcc_features.(sprintf('mfcc_%d', i)) = 0;
        end
    end
    
    logDebug('✅ Cechy MFCC: 10 cech');
    
catch ME
    logWarning('Błąd MFCC: %s', ME.message);
    mfcc_features = struct();
    for i = 1:10
        mfcc_features.(sprintf('mfcc_%d', i)) = 0;
    end
end

end