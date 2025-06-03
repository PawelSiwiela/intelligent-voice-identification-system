function [X_selected, selected_names] = selectFeaturesForScenario(X, scenario, feature_config)

% POPRAWIONE MAPOWANIE CECH NA PODSTAWIE RZECZYWISTEJ KOLEJNOŚCI
basic_idx = 1:8;           % mean, std, rms, range, zcr, variance, skewness, kurtosis
envelope_idx = 9:15;       % upper_mean, upper_std, lower_mean, lower_std, diff_mean, env_ratio, env_range
spectral_idx = 16:20;      % centroid, rolloff, flatness, flux, bandwidth
fft_idx = 21:25;          % fft_range_1, fft_range_2, fft_range_3, dominant_freq, total_energy
formant_idx = 26:30;       % f1, f2, f3, f2_f1_ratio, formant_bandwidth
mfcc_idx = 31:40;         % mfcc_1 do mfcc_10

% Domyślna konfiguracja jeśli nie podano
if nargin < 3
    feature_config = struct('feature_selection', 'optimized');
end

switch feature_config.feature_selection
    case 'all'
        % Użyj wszystkich dostępnych cech
        selected_idx = 1:size(X, 2);
        selected_names = arrayfun(@(i) sprintf('feature_%d', i), selected_idx, 'UniformOutput', false);
        
        logInfo('🌟 Użyto wszystkich %d dostępnych cech', length(selected_idx));
        
    case 'custom'
        % Użyj N najważniejszych cech dla scenariusza
        [all_idx, all_names] = getOptimalFeaturesForScenario(scenario);
        desired_count = min(feature_config.desired_features, length(all_idx));
        
        selected_idx = all_idx(1:desired_count);
        selected_names = all_names(1:desired_count);
        
        logInfo('🎯 Użyto %d najważniejszych cech dla scenariusza %s', desired_count, scenario);
        
    case 'optimized'
    otherwise
        % POPRAWIONA OPTYMALIZACJA SCENARIUSZ-SPECYFICZNA
        switch scenario
            case 'vowels'
                % Dla samogłosek: FORMANTY (kluczowe) + część MFCC + podstawowe spektralne
                selected_idx = [formant_idx, mfcc_idx(1:6), spectral_idx(1:3), basic_idx(3)];  % 5+6+3+1 = 15 cech
                
                selected_names = {
                    'formant_f1', 'formant_f2', 'formant_f3', 'formant_f2_f1_ratio', 'formant_bandwidth', ...
                    'mfcc_1', 'mfcc_2', 'mfcc_3', 'mfcc_4', 'mfcc_5', 'mfcc_6', ...
                    'spectral_centroid', 'spectral_rolloff', 'spectral_flatness', ...
                    'basic_rms'
                    };
                
                logInfo('🔊 Cechy dla samogłosek: 5 formantów + 6 MFCC + 3 spektralne + 1 podstawowa = %d cech', ...
                    length(selected_idx));
                
            case 'commands'
                % Dla komend: BASIC temporal + ENVELOPE dynamika + część MFCC + FFT energia
                selected_idx = [basic_idx([3,5,6,7,8]), envelope_idx([1,2,5,6,7]), mfcc_idx(1:5), fft_idx, spectral_idx(1:2)];  % 5+5+5+5+2 = 22 cechy
                
                selected_names = {
                    'basic_rms', 'basic_zcr', 'basic_variance', 'basic_skewness', 'basic_kurtosis', ...
                    'env_upper_mean', 'env_upper_std', 'env_diff_mean', 'env_ratio', 'env_range', ...
                    'mfcc_1', 'mfcc_2', 'mfcc_3', 'mfcc_4', 'mfcc_5', ...
                    'fft_range_1', 'fft_range_2', 'fft_range_3', 'fft_dominant_freq', 'fft_total_energy', ...
                    'spectral_centroid', 'spectral_rolloff'
                    };
                
                logInfo('💬 Cechy dla komend: 5 basic + 5 envelope + 5 MFCC + 5 FFT + 2 spektralne = %d cech', ...
                    length(selected_idx));
                
            case 'all'
                % Dla wszystkich: zrównoważony zestaw wszystkich typów
                selected_idx = [formant_idx(1:3), mfcc_idx(1:8), basic_idx([3,5,6]), envelope_idx([1,5,6]), spectral_idx(1:3), fft_idx(1:3)];  % 3+8+3+3+3+3 = 23 cechy
                
                selected_names = {
                    'formant_f1', 'formant_f2', 'formant_f3', ...
                    'mfcc_1', 'mfcc_2', 'mfcc_3', 'mfcc_4', 'mfcc_5', 'mfcc_6', 'mfcc_7', 'mfcc_8', ...
                    'basic_rms', 'basic_zcr', 'basic_variance', ...
                    'env_upper_mean', 'env_diff_mean', 'env_ratio', ...
                    'spectral_centroid', 'spectral_rolloff', 'spectral_flatness', ...
                    'fft_range_1', 'fft_range_2', 'fft_range_3'
                    };
                
                logInfo('🌐 Cechy dla wszystkich: 3 formanty + 8 MFCC + 3 basic + 3 envelope + 3 spektralne + 3 FFT = %d cech', ...
                    length(selected_idx));
        end
end

% Sprawdzenie czy indeksy nie przekraczają dostępnych cech
max_available = size(X, 2);
selected_idx = selected_idx(selected_idx <= max_available);

% Selekcja cech
X_selected = X(:, selected_idx);

% Sprawdzenie efektywności redukcji
reduction_percent = (1 - length(selected_idx)/max_available) * 100;
logInfo('📉 Redukcja wymiarowości: %.1f%% (z %d do %d cech)', ...
    reduction_percent, max_available, length(selected_idx));

end

% =========================================================================
% ZAKTUALIZOWANA FUNKCJA POMOCNICZA
% =========================================================================

function [optimal_idx, optimal_names] = getOptimalFeaturesForScenario(scenario)

% POPRAWIONE INDEKSY
basic_idx = 1:8;
envelope_idx = 9:15;
spectral_idx = 16:20;
fft_idx = 21:25;
formant_idx = 26:30;
mfcc_idx = 31:40;

switch scenario
    case 'vowels'
        % Dla samogłosek: formanty najważniejsze, potem MFCC, spektralne, basic
        optimal_idx = [formant_idx, mfcc_idx, spectral_idx, basic_idx([3,5,6]), envelope_idx([1,5])];
        optimal_names = [
            {'formant_f1', 'formant_f2', 'formant_f3', 'formant_f2_f1_ratio', 'formant_bandwidth'}, ...
            arrayfun(@(i) sprintf('mfcc_%d', i), 1:10, 'UniformOutput', false), ...
            {'spectral_centroid', 'spectral_rolloff', 'spectral_flatness', 'spectral_flux', 'spectral_bandwidth'}, ...
            {'basic_rms', 'basic_zcr', 'basic_variance'}, ...
            {'env_upper_mean', 'env_diff_mean'}
            ];
        
    case 'commands'
        % Dla komend: basic i envelope najważniejsze, potem FFT, MFCC, spektralne
        optimal_idx = [basic_idx, envelope_idx, fft_idx, mfcc_idx, spectral_idx, formant_idx];
        optimal_names = [
            {'basic_mean', 'basic_std', 'basic_rms', 'basic_range', 'basic_zcr', 'basic_variance', 'basic_skewness', 'basic_kurtosis'}, ...
            {'env_upper_mean', 'env_upper_std', 'env_lower_mean', 'env_lower_std', 'env_diff_mean', 'env_ratio', 'env_range'}, ...
            {'fft_range_1', 'fft_range_2', 'fft_range_3', 'fft_dominant_freq', 'fft_total_energy'}, ...
            arrayfun(@(i) sprintf('mfcc_%d', i), 1:10, 'UniformOutput', false), ...
            {'spectral_centroid', 'spectral_rolloff', 'spectral_flatness', 'spectral_flux', 'spectral_bandwidth'}, ...
            {'formant_f1', 'formant_f2', 'formant_f3', 'formant_f2_f1_ratio', 'formant_bandwidth'}
            ];
        
    case 'all'
        % Dla wszystkich: zrównoważone podejście
        optimal_idx = [mfcc_idx, formant_idx, basic_idx([3,5,6,7,8]), envelope_idx([1,2,5,6]), spectral_idx, fft_idx];
        optimal_names = [
            arrayfun(@(i) sprintf('mfcc_%d', i), 1:10, 'UniformOutput', false), ...
            {'formant_f1', 'formant_f2', 'formant_f3', 'formant_f2_f1_ratio', 'formant_bandwidth'}, ...
            {'basic_rms', 'basic_zcr', 'basic_variance', 'basic_skewness', 'basic_kurtosis'}, ...
            {'env_upper_mean', 'env_upper_std', 'env_diff_mean', 'env_ratio'}, ...
            {'spectral_centroid', 'spectral_rolloff', 'spectral_flatness', 'spectral_flux', 'spectral_bandwidth'}, ...
            {'fft_range_1', 'fft_range_2', 'fft_range_3', 'fft_dominant_freq', 'fft_total_energy'}
            ];
end

end