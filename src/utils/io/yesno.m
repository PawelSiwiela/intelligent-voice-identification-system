function str = yesno(logical_val)
% =========================================================================
% KONWERSJA WARTOŚCI LOGICZNEJ NA TEKST
% =========================================================================
% Konwertuje wartość true/false na czytelny tekst TAK/NIE
% =========================================================================

if logical_val
    str = 'TAK';
else
    str = 'NIE';
end

end