function compatible = validateConfiguration(loaded_data, use_vowels, use_complex)
% Sprawdza czy konfiguracja w pliku jest zgodna z aktualną
compatible = true;

if isfield(loaded_data, 'use_vowels') && isfield(loaded_data, 'use_complex')
    if loaded_data.use_vowels ~= use_vowels || loaded_data.use_complex ~= use_complex
        fprintf('⚠️ Wykryto niezgodność konfiguracji:\n');
        fprintf('   📁 Plik: samogłoski=%s, pary słów=%s\n', ...
            yesno(loaded_data.use_vowels), yesno(loaded_data.use_complex));
        fprintf('   🔄 Aktualna: samogłoski=%s, pary słów=%s\n', ...
            yesno(use_vowels), yesno(use_complex));
        fprintf('   ⚡ Przetwarzanie danych od nowa...\n');
        fprintf('   💡 Uwaga: zmiana konfiguracji może wpłynąć na jakość rozpoznawania.\n');
        compatible = false;
    end
else
    fprintf('⚠️ Brak informacji o konfiguracji w pliku. Przetwarzanie od nowa...\n');
    compatible = false;
end
end