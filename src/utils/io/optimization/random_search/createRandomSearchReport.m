function createRandomSearchReport(random_results, best_params, method)
% =========================================================================
% TWORZENIE RAPORTU RANDOM SEARCH
% =========================================================================

try
    if isempty(random_results)
        logWarning('⚠️ Brak wyników do raportu Random Search');
        return;
    end
    
    % Sortowanie wyników według accuracy
    accuracies = zeros(length(random_results), 1);
    for i = 1:length(random_results)
        if isfield(random_results(i), 'accuracy')
            accuracies(i) = random_results(i).accuracy;
        else
            accuracies(i) = 0;
        end
    end
    
    [~, sorted_idx] = sort(accuracies, 'descend');
    sorted_results = random_results(sorted_idx);
    
    % =====================================================================
    % TOP 5 KONFIGURACJI
    % =====================================================================
    logInfo('🏅 TOP 5 KONFIGURACJI RANDOM SEARCH:');
    logInfo('=====================================');
    
    top_count = min(5, length(sorted_results));
    for i = 1:top_count
        result = sorted_results(i);
        if isfield(result, 'accuracy')
            log_msg = sprintf('%d. %.1f%%', i, result.accuracy*100);
            
            % Dodaj dostępne informacje
            if isfield(result, 'architecture')
                log_msg = [log_msg, sprintf(' - %s', result.architecture)];
            end
            if isfield(result, 'hidden_layers')
                log_msg = [log_msg, sprintf(', layers=%s', mat2str(result.hidden_layers))];
            end
            if isfield(result, 'train_function')
                log_msg = [log_msg, sprintf(', %s', result.train_function)];
            end
            if isfield(result, 'learning_rate')
                log_msg = [log_msg, sprintf(', lr=%.3f', result.learning_rate)];
            end
            
            logInfo(log_msg);
        end
    end
    
    % =====================================================================
    % STATYSTYKI RANDOM SEARCH
    % =====================================================================
    logInfo('');
    logInfo('📊 STATYSTYKI RANDOM SEARCH:');
    logInfo('============================');
    
    mean_acc = mean(accuracies) * 100;
    std_acc = std(accuracies) * 100;
    max_acc = max(accuracies) * 100;
    min_acc = min(accuracies) * 100;
    
    logInfo('   📈 Średnia accuracy: %.1f%% (±%.1f%%)', mean_acc, std_acc);
    logInfo('   🏆 Najlepsza accuracy: %.1f%%', max_acc);
    logInfo('   📉 Najgorsza accuracy: %.1f%%', min_acc);
    logInfo('   🎯 Zakres: %.1f%% - %.1f%%', min_acc, max_acc);
    
    % Ile iteracji powyżej średniej
    above_mean = sum(accuracies > mean(accuracies));
    logInfo('   ⬆️ Powyżej średniej: %d/%d (%.1f%%)', ...
        above_mean, length(accuracies), 100*above_mean/length(accuracies));
    
    % =====================================================================
    % ROZKŁAD PER ARCHITEKTURA
    % =====================================================================
    architectures = {};
    arch_accuracies = {};
    
    for i = 1:length(random_results)
        if isfield(random_results(i), 'network_architecture') && isfield(random_results(i), 'accuracy')
            arch = random_results(i).network_architecture;
            acc = random_results(i).accuracy;
            
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
    logInfo('📊 ŚREDNIA ACCURACY PER ARCHITEKTURA:');
    for i = 1:length(architectures)
        mean_acc = mean(arch_accuracies{i}) * 100;
        count = length(arch_accuracies{i});
        if ~isnan(mean_acc)
            logInfo('   %s: %.1f%% (%d prób)', architectures{i}, mean_acc, count);
        end
    end
    
catch ME
    logError('❌ Błąd tworzenia raportu Random Search: %s', ME.message);
end

end