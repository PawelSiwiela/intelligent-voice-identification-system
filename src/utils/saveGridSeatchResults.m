function saveGridSearchResults(grid_results, best_params, best_net, config, total_time)
% Zapisuje wyniki Grid Search
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
results_filename = sprintf('output/results/grid_search_results_%s.mat', timestamp);
best_net_filename = sprintf('output/networks/best_network_gridsearch_%s.mat', timestamp);

% Zapisanie szczegółowych wyników
save(results_filename, 'grid_results', 'best_params', 'config', 'total_time');

% Zapisanie najlepszej sieci
save(best_net_filename, 'best_net', 'best_params');

logSuccess('💾 Wyniki Grid Search zapisane:');
logInfo('   📊 Szczegóły: %s', results_filename);
logInfo('   🧠 Najlepsza sieć: %s', best_net_filename);
end