function saveRandomSearchResults(random_results, best_params, best_net, method, total_time)
% =========================================================================
% ZAPISYWANIE WYNIKÓW RANDOM SEARCH
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
    results_filename = sprintf('output/results/random_search_results_%s.mat', timestamp);
    best_net_filename = sprintf('output/networks/best_network_randomsearch_%s.mat', timestamp);
    
    % Zapisanie szczegółowych wyników
    if ~isempty(random_results)
        save(results_filename, 'random_results', 'best_params', 'method', 'total_time');
        logSuccess('💾 Wyniki Random Search zapisane: %s', results_filename);
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
    logInfo('📋 Podsumowanie Random Search:');
    logInfo('   📊 Przetestowanych kombinacji: %d', length(random_results));
    
    if isfield(best_params, 'accuracy')
        logInfo('   🏆 Najlepsza accuracy: %.2f%%', best_params.accuracy*100);
    end
    
    logInfo('   ⏱️ Całkowity czas: %.1f s (%.1f min)', total_time, total_time/60);
    logInfo('   ⚡ Średni czas na iterację: %.1f s', total_time/length(random_results));
    
catch ME
    logError('❌ Błąd zapisywania wyników Random Search: %s', ME.message);
end

end