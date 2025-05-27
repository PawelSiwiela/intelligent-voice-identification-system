function saveGridSearchResults(grid_results, best_params, best_net, config, total_time)
% =========================================================================
% ZAPISYWANIE WYNIKÓW GRID SEARCH
% =========================================================================

try
    % Utworzenie timestamp
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    
    % Sprawdzenie czy katalogi istnieją
    if ~exist('output/results', 'dir')
        mkdir('output/results');
    end
    
    if ~exist('output/networks', 'dir')
        mkdir('output/networks');
    end
    
    % Nazwy plików
    results_filename = sprintf('output/results/grid_search_results_%s.mat', timestamp);
    best_net_filename = sprintf('output/networks/best_network_gridsearch_%s.mat', timestamp);
    
    % Zapisanie szczegółowych wyników
    if ~isempty(grid_results)
        save(results_filename, 'grid_results', 'best_params', 'config', 'total_time');
        logSuccess('💾 Wyniki Grid Search zapisane: %s', results_filename);
    else
        logWarning('⚠️ Brak wyników do zapisania');
    end
    
    % Zapisanie najlepszej sieci
    if ~isempty(best_net)
        save(best_net_filename, 'best_net', 'best_params');
        logSuccess('💾 Najlepsza sieć zapisana: %s', best_net_filename);
    else
        logWarning('⚠️ Brak najlepszej sieci do zapisania');
    end
    
    % Podsumowanie zapisu
    logInfo('📋 Podsumowanie zapisu:');
    logInfo('   📊 Przetestowanych kombinacji: %d', length(grid_results));
    
    if isfield(best_params, 'accuracy')
        logInfo('   🏆 Najlepsza accuracy: %.2f%%', best_params.accuracy*100);
    end
    
    logInfo('   ⏱️ Całkowity czas: %.1f s', total_time);
    
catch ME
    logError('❌ Błąd zapisywania wyników: %s', ME.message);
end

end