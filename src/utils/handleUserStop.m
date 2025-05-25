function handleUserStop(h_main, X, Y, labels, successful_loads, failed_loads, normalize_features_flag)
% Obsługuje zatrzymanie procesu przez użytkownika
logInfo('🛑 Przetwarzanie zostało zatrzymane przez użytkownika!');
logInfo('📊 Wczytano %d próbek przed zatrzymaniem.', successful_loads);

if isvalid(h_main)
    close(h_main);
end

% Zapisanie częściowych danych (jeśli istnieją)
if ~isempty(X)
    config_string = 'partial';
    if normalize_features_flag
        data_filename = sprintf('loaded_audio_data_%s_normalized_PARTIAL.mat', config_string);
    else
        data_filename = sprintf('loaded_audio_data_%s_raw_PARTIAL.mat', config_string);
    end
    
    partial_file_path = fullfile('output', 'preprocessed', data_filename);
    
    save(partial_file_path, 'X', 'Y', 'labels', 'successful_loads', 'failed_loads');
    logSuccess('💾 Częściowe dane zapisane jako: %s', partial_file_path);
end
end