function createGridSearchReport(grid_results, best_params, labels)
% Tworzy szczegółowy raport Grid Search

if isempty(grid_results)
    logWarning('⚠️ Brak wyników do raportu');
    return;
end

% Sortowanie wyników
performances = [grid_results.cv_performance];
[~, sort_idx] = sort(performances, 'descend');
sorted_results = grid_results(sort_idx);

% Top 5 wyników
top_n = min(5, length(sorted_results));
logInfo('');
logInfo('🏅 TOP %d KONFIGURACJI:', top_n);
logInfo('=====================');

for i = 1:top_n
    result = sorted_results(i);
    logInfo('%d. %.2f%% - %s, layers=[%s], %s, lr=%.3f', ...
        i, result.cv_performance*100, result.architecture, ...
        num2str(result.hidden_layers), result.training_function, result.learning_rate);
end

% Analiza najlepszych architektur
architectures = {grid_results.architecture};
unique_archs = unique(architectures);
logInfo('');
logInfo('📊 ŚREDNIA DOKŁADNOŚĆ PER ARCHITEKTURA:');
for i = 1:length(unique_archs)
    arch_mask = strcmp(architectures, unique_archs{i});
    arch_performances = performances(arch_mask);
    avg_perf = mean(arch_performances);
    logInfo('   %s: %.2f%%', unique_archs{i}, avg_perf*100);
end

logInfo('');
end