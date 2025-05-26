function displayBestConfiguration(best_params)
% Wyświetla najlepszą konfigurację
logInfo('🏆 NAJLEPSZA KONFIGURACJA:');
logInfo('   🏗️ Architektura: %s', best_params.architecture);
logInfo('   📊 Warstwy ukryte: [%s]', num2str(best_params.hidden_layers));
logInfo('   🧠 Funkcja trenowania: %s', best_params.training_function);
logInfo('   ⚡ Funkcja aktywacji: %s', best_params.activation_function);
logInfo('   📈 Learning rate: %.3f', best_params.learning_rate);
logInfo('   🔄 Epoki: %d', best_params.epochs);
logInfo('   🎯 Goal: %.1e', best_params.goal);
logInfo('   ⏱️ Czas trenowania: %.2f s', best_params.training_time);
logInfo('   🎯 CV accuracy: %.2f%% (±%.2f%%)', ...
    best_params.cv_performance*100, best_params.cv_std*100);
end