function createGridSearchReport(grid_results, best_params, config, output_dir)
% =========================================================================
% TWORZENIE RAPORTU GRID SEARCH - BEZ CV_PERFORMANCE
% =========================================================================

try
    if isempty(grid_results)
        logWarning('⚠️ Brak wyników do raportu');
        return;
    end
    
    % Sortowanie wyników według accuracy
    accuracies = zeros(length(grid_results), 1);
    for i = 1:length(grid_results)
        if isfield(grid_results(i), 'accuracy')
            accuracies(i) = grid_results(i).accuracy;
        else
            accuracies(i) = 0;
        end
    end
    
    [~, sorted_idx] = sort(accuracies, 'descend');
    sorted_results = grid_results(sorted_idx);
    
    % =====================================================================
    % TOP 5 KONFIGURACJI
    % =====================================================================
    logInfo('🏅 TOP 5 KONFIGURACJI:');
    logInfo('=====================');
    
    top_count = min(5, length(sorted_results));
    for i = 1:top_count
        result = sorted_results(i);
        if isfield(result, 'accuracy') && isfield(result, 'network_architecture')
            logInfo('%d. %.1f%% - %s, layers=%s, %s, lr=%.3f', ...
                i, result.accuracy*100, result.network_architecture, ...
                mat2str(result.hidden_layers), result.training_function, ...
                result.learning_rate);
        end
    end
    
    % =====================================================================
    % ŚREDNIA DOKŁADNOŚĆ PER ARCHITEKTURA
    % =====================================================================
    architectures = {};
    arch_accuracies = {};
    
    for i = 1:length(grid_results)
        if isfield(grid_results(i), 'network_architecture') && isfield(grid_results(i), 'accuracy')
            arch = grid_results(i).network_architecture;
            acc = grid_results(i).accuracy;
            
            arch_idx = find(strcmp(architectures, arch));
            if isempty(arch_idx)
                architectures{end+1} = arch;
                arch_accuracies{end+1} = acc;
            else
                arch_accuracies{arch_idx} = [arch_accuracies{arch_idx}, acc];
            end
        end
    end
    
    logInfo('');
    logInfo('📊 ŚREDNIA DOKŁADNOŚĆ PER ARCHITEKTURA:');
    for i = 1:length(architectures)
        mean_acc = mean(arch_accuracies{i}) * 100;
        if ~isnan(mean_acc)
            logInfo('   %s: %.1f%%', architectures{i}, mean_acc);
        else
            logInfo('   %s: NaN%%', architectures{i});
        end
    end
    
catch ME
    logError('❌ Błąd tworzenia raportu: %s', ME.message);
end

end