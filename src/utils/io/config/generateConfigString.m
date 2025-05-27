function config_string = generateConfigString(use_vowels, use_complex)
% =========================================================================
% GENEROWANIE STRINGA KONFIGURACJI
% =========================================================================
% Tworzy unikatowy string identyfikujący konfigurację danych
%
% ARGUMENTY:
%   use_vowels - czy używać samogłosek (true/false)
%   use_complex - czy używać komend złożonych (true/false)
%
% ZWRACA:
%   config_string - string opisujący konfigurację
% =========================================================================

% Określenie typu danych na podstawie flag
if use_vowels && use_complex
    config_string = 'vowels_and_complex';
elseif use_vowels
    config_string = 'vowels_only';
elseif use_complex
    config_string = 'complex_only';
else
    config_string = 'no_data';
end

end