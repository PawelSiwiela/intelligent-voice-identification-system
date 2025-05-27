function displayFinalSummary(total_start, loading_time, results, ...
    noise_level, num_samples, use_vowels, use_complex, normalize_features, data_file)
% Wyświetla finalne podsumowanie całego procesu

total_time = toc(total_start);

logInfo('🎯 PODSUMOWANIE KOŃCOWE');
logInfo('=======================');
logInfo('⏱️ Całkowity czas wykonania: %.2f sekund (%.2f minut)', ...
    total_time, total_time/60);
logInfo('   📦 Wczytywanie danych: %.2f sekund (%.1f%%)', ...
    loading_time, 100*loading_time/total_time);

if isfield(results, 'training_time')
    logInfo('   🧠 Trenowanie sieci: %.2f sekund (%.1f%%)', ...
        results.training_time, 100*results.training_time/total_time);
end

if isfield(results, 'testing_time')
    logInfo('   🧪 Testowanie sieci: %.2f sekund (%.1f%%)\n', ...
        results.testing_time, 100*results.testing_time/total_time);
end

if isfield(results, 'accuracy')
    logSuccess('🎯 Osiągnięta dokładność: %.2f%%', results.accuracy * 100);
end

logInfo(''); % Pusta linia
logInfo('📋 SZCZEGÓŁY KONFIGURACJI');
logInfo('=========================');
logInfo('🔊 Poziom szumu: %.1f\n', noise_level);
logInfo('📝 Próbek na kategorię: %d\n', num_samples);
logInfo('🎵 Samogłoski: %s\n', yesno(use_vowels));
logInfo('💬 Komendy złożone: %s\n', yesno(use_complex));
logInfo('⚖️ Normalizacja cech: %s\n', yesno(normalize_features));

if exist(data_file, 'file')
    logInfo('💾 Źródło danych: plik %s\n', data_file);
else
    logInfo('💾 Źródło danych: przetwarzanie na żywo\n');
end

logInfo('🎉 System rozpoznawania głosu został pomyślnie uruchomiony!');
end