function closeLog()
% =========================================================================
% ZAMKNIĘCIE PLIKU LOG
% =========================================================================
% Bezpiecznie zamyka plik log na końcu programu

persistent log_file_handle;

% Dostęp do zmiennych z writeLog
log_vars = evalin('base', 'who');
if ismember('log_file_handle', log_vars)
    log_file_handle = evalin('base', 'log_file_handle');
end

% Alternatywnie - użyj globalnej zmiennej
global LOG_FILE_HANDLE;

if ~isempty(LOG_FILE_HANDLE) && LOG_FILE_HANDLE ~= -1
    % Zapis końcowego komunikatu
    fprintf(LOG_FILE_HANDLE, '\n========================================\n');
    fprintf(LOG_FILE_HANDLE, 'Log zakończony: %s\n', datestr(now));
    fprintf(LOG_FILE_HANDLE, '========================================\n');
    
    % Zamknięcie pliku
    fclose(LOG_FILE_HANDLE);
    LOG_FILE_HANDLE = [];
    
    fprintf('📝 Plik log został zamknięty\n');
end

end