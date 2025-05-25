function displayLoadingSummary(loading_time, successful_loads, failed_loads)
% Wyświetla podsumowanie procesu wczytywania
logInfo('📈 Statystyki wczytywania:');
logInfo('   ⏱️ Czas: %.2f sekund (%.2f minut)', loading_time, loading_time/60);
logInfo('   ✅ Udane wczytania: %d', successful_loads);
logInfo('   ❌ Nieudane wczytania: %d', failed_loads);

if failed_loads > 0
    success_rate = 100 * successful_loads / (successful_loads + failed_loads);
    logInfo('   📊 Wskaźnik sukcesu: %.1f%%', success_rate);
end
end