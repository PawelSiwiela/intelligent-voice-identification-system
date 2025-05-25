function config_str = generateConfigString(use_vowels, use_complex)
% Generuje string konfiguracji na podstawie używanych kategorii danych
if use_vowels && use_complex
    config_str = 'vowels_complex';
elseif use_vowels
    config_str = 'vowels_only';
elseif use_complex
    config_str = 'complex_only';
else
    config_str = 'empty';
end
end
