function displayLoadingSummary(loading_time, successful_loads, failed_loads)
% Wyświetla podsumowanie procesu wczytywania
fprintf('\n📈 Statystyki wczytywania:\n');
fprintf('   ⏱️ Czas: %.2f sekund (%.2f minut)\n', loading_time, loading_time/60);
fprintf('   ✅ Udane wczytania: %d\n', successful_loads);
fprintf('   ❌ Nieudane wczytania: %d\n', failed_loads);

if failed_loads > 0
    success_rate = 100 * successful_loads / (successful_loads + failed_loads);
    fprintf('   📊 Wskaźnik sukcesu: %.1f%%\n', success_rate);
end
end