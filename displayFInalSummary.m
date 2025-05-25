function displayFinalSummary(total_start, loading_time, results, ...
    noise_level, num_samples, use_vowels, use_complex, normalize_features, data_file)
% Wyświetla finalne podsumowanie całego procesu

total_time = toc(total_start);

fprintf('\n🎯 PODSUMOWANIE KOŃCOWE\n');
fprintf('=======================\n');
fprintf('⏱️ Całkowity czas wykonania: %.2f sekund (%.2f minut)\n', ...
    total_time, total_time/60);
fprintf('   📦 Wczytywanie danych: %.2f sekund (%.1f%%)\n', ...
    loading_time, 100*loading_time/total_time);

if isfield(results, 'training_time')
    fprintf('   🧠 Trenowanie sieci: %.2f sekund (%.1f%%)\n', ...
        results.training_time, 100*results.training_time/total_time);
end

if isfield(results, 'testing_time')
    fprintf('   🧪 Testowanie sieci: %.2f sekund (%.1f%%)\n', ...
        results.testing_time, 100*results.testing_time/total_time);
end

if isfield(results, 'accuracy')
    fprintf('\n🎯 Osiągnięta dokładność: %.2f%%\n', results.accuracy * 100);
end

fprintf('\n📋 SZCZEGÓŁY KONFIGURACJI\n');
fprintf('=========================\n');
fprintf('🔊 Poziom szumu: %.1f\n', noise_level);
fprintf('📝 Próbek na kategorię: %d\n', num_samples);
fprintf('🎵 Samogłoski: %s\n', yesno(use_vowels));
fprintf('💬 Komendy złożone: %s\n', yesno(use_complex));
fprintf('⚖️ Normalizacja cech: %s\n', yesno(normalize_features));

if exist(data_file, 'file')
    fprintf('💾 Źródło danych: plik %s\n', data_file);
else
    fprintf('💾 Źródło danych: przetwarzanie na żywo\n');
end

fprintf('\n🎉 System rozpoznawania głosu został pomyślnie uruchomiony!\n');
end