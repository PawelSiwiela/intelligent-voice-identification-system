function saveGoldenParameters(golden_params, accuracy, iteration)
% =========================================================================
% ZAPISYWANIE GOLDEN PARAMETERS - PARAMETRÓW DAJĄCYCH 95%+
% =========================================================================

try
    % Timestamp
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    
    % Sprawdzenie katalogu
    if ~exist('output/golden', 'dir')
        mkdir('output/golden');
    end
    
    % Nazwa pliku z accuracy w nazwie
    filename = sprintf('output/golden/GOLDEN_PARAMS_%.1f%%_%s.mat', ...
        accuracy*100, timestamp);
    
    % Dodanie metadanych
    golden_params.found_at_iteration = iteration;
    golden_params.discovery_time = datestr(now);
    golden_params.method = 'random_search_early_stopping';
    golden_params.target_reached = accuracy;
    
    % Zapis
    save(filename, 'golden_params');
    
    logSuccess('💎 GOLDEN PARAMETERS zapisane: %s', filename);
    logSuccess('🎯 Użyj tych parametrów do treningu finalnej sieci!');
    
    % Opcjonalnie - stwórz też plik tekstowy dla łatwego odczytu
    txt_filename = sprintf('output/golden/GOLDEN_PARAMS_%.1f%%_%s.txt', ...
        accuracy*100, timestamp);
    
    fid = fopen(txt_filename, 'w');
    if fid ~= -1
        fprintf(fid, '=== GOLDEN PARAMETERS - %.1f%% ACCURACY ===\n', accuracy*100);
        fprintf(fid, 'Znalezione w iteracji: %d\n', iteration);
        fprintf(fid, 'Data: %s\n', datestr(now));
        fprintf(fid, '\nPARAMETRY:\n');
        fprintf(fid, 'Architektura: %s\n', mat2str(golden_params.hidden_layers));
        fprintf(fid, 'Funkcja treningu: %s\n', golden_params.train_function);
        fprintf(fid, 'Learning rate: %.6f\n', golden_params.learning_rate);
        fprintf(fid, 'Funkcja aktywacji: %s\n', golden_params.activation_function);
        fprintf(fid, 'Epoki: %d\n', golden_params.epochs);
        fprintf(fid, 'Accuracy: %.4f (%.1f%%)\n', accuracy, accuracy*100);
        fclose(fid);
        
        logInfo('📄 Golden parameters zapisane też jako TXT: %s', txt_filename);
    end
    
catch ME
    logError('❌ Błąd zapisywania Golden Parameters: %s', ME.message);
end

end