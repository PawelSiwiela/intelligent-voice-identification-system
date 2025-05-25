function compatible = validateConfiguration(loaded_data, use_vowels, use_complex)
% =========================================================================
% WALIDACJA ZGODNOŚCI KONFIGURACJI
% =========================================================================
% Sprawdza czy konfiguracja w pliku jest zgodna z aktualną
% =========================================================================

compatible = true;

if isfield(loaded_data, 'use_vowels') && isfield(loaded_data, 'use_complex')
    if loaded_data.use_vowels ~= use_vowels || loaded_data.use_complex ~= use_complex
        logWarning('⚠️ Wykryto niezgodność konfiguracji:');
        logInfo('   📁 Plik: samogłoski=%s, pary słów=%s', ...
            yesno(loaded_data.use_vowels), yesno(loaded_data.use_complex));
        logInfo('   🔄 Aktualna: samogłoski=%s, pary słów=%s', ...
            yesno(use_vowels), yesno(use_complex));
        logInfo('   ⚡ Przetwarzanie danych od nowa...');
        compatible = false;
    end
else
    logInfo('⚠️ Brak informacji o konfiguracji w pliku. Przetwarzanie od nowa...\n');
    compatible = false;
end

end