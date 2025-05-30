function closeLog()
% CLOSELOG Bezpiecznie zamyka plik log na końcu programu
%
% Składnia:
%   closeLog()
%
% Ta funkcja powinna być wywołana przed zakończeniem programu,
% aby zapewnić poprawne zamknięcie pliku logu.

% Dostęp do globalnej zmiennej przechowującej uchwyt do pliku
global LOG_FILE_HANDLE;

% Sprawdź czy plik jest otwarty
if ~isempty(LOG_FILE_HANDLE) && LOG_FILE_HANDLE ~= -1
    % Zapis końcowego komunikatu
    fprintf(LOG_FILE_HANDLE, '\n========================================\n');
    fprintf(LOG_FILE_HANDLE, 'Log zakończony: %s\n', datestr(now));
    fprintf(LOG_FILE_HANDLE, '========================================\n');
    
    % Zamknięcie pliku
    fclose(LOG_FILE_HANDLE);
    LOG_FILE_HANDLE = -1;
    
    fprintf('📝 Plik log został zamknięty\n');
end
end