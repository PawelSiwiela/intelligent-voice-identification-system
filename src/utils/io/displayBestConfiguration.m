function displayBestConfiguration(best_params)
% =========================================================================
% WYŚWIETLANIE NAJLEPSZEJ KONFIGURACJI
% =========================================================================

try
    logInfo('🏆 NAJLEPSZA KONFIGURACJA:');
    
    % Sprawdź czy pola istnieją przed użyciem
    if isfield(best_params, 'network_architecture')
        logInfo('   🏗️ Architektura: %s', best_params.network_architecture);
    end
    
    if isfield(best_params, 'hidden_layers')
        logInfo('   📊 Warstwy ukryte: %s', mat2str(best_params.hidden_layers));
    end
    
    if isfield(best_params, 'training_function')
        logInfo('   🧠 Funkcja trenowania: %s', best_params.training_function);
    end
    
    if isfield(best_params, 'activation_function')
        logInfo('   ⚡ Funkcja aktywacji: %s', best_params.activation_function);
    end
    
    if isfield(best_params, 'learning_rate')
        logInfo('   📈 Learning rate: %.3f', best_params.learning_rate);
    end
    
    if isfield(best_params, 'epochs')
        logInfo('   🔄 Epoki: %d', best_params.epochs);
    end
    
    if isfield(best_params, 'performance_goal')
        logInfo('   🎯 Goal: %.1e', best_params.performance_goal);
    end
    
    if isfield(best_params, 'training_time')
        logInfo('   ⏱️ Czas trenowania: %.2f s', best_params.training_time);
    end
    
    if isfield(best_params, 'cv_performance')
        logInfo('   🎯 CV accuracy: %.2f%%', best_params.cv_performance * 100);
    end
    
catch ME
    logError('❌ Błąd wyświetlania konfiguracji: %s', ME.message);
end

end