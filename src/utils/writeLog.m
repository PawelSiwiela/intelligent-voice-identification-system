function writeLog(level, message, varargin)
% =========================================================================
% SYSTEM LOGOWANIA
% =========================================================================
% Zapisuje komunikaty do pliku log i wyświetla w konsoli
%
% ARGUMENTY:
%   level - poziom logu: 'DEBUG', 'INFO', 'WARNING', 'ERROR'
%   message - treść komunikatu (może zawierać formatowanie sprintf)
%   varargin - dodatkowe argumenty dla sprintf
% =========================================================================

% UŻYJ GLOBALNYCH ZMIENNYCH zamiast persistent
global LOG_FILE_HANDLE LOG_ENABLED CURRENT_LOG_FILE;

% Inicjalizacja przy pierwszym wywołaniu
if isempty(LOG_ENABLED)
    fprintf('🔧 DEBUG: Inicjalizacja systemu logowania...\n');
    
    LOG_ENABLED = true;
    
    % Utworzenie nazwy pliku log z timestampem
    timestamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
    log_filename = sprintf('voice_recognition_%s.log', timestamp);
    
    % Sprawdzenie czy katalog logs istnieje
    logs_dir = 'output/logs';
    if ~exist(logs_dir, 'dir')
        mkdir(logs_dir);
        fprintf('🔧 DEBUG: Utworzono katalog %s\n', logs_dir);
    end
    
    CURRENT_LOG_FILE = fullfile(logs_dir, log_filename);
    fprintf('🔧 DEBUG: Próba utworzenia pliku: %s\n', CURRENT_LOG_FILE);
    
    % Otwarcie pliku do zapisu
    LOG_FILE_HANDLE = fopen(CURRENT_LOG_FILE, 'w', 'n', 'UTF-8');
    
    if LOG_FILE_HANDLE == -1
        warning('❌ Nie można utworzyć pliku log: %s', CURRENT_LOG_FILE);
        LOG_ENABLED = false;
    else
        fprintf('✅ Plik log utworzony pomyślnie: %s\n', CURRENT_LOG_FILE);
        % Nagłówek pliku log
        fprintf(LOG_FILE_HANDLE, '========================================\n');
        fprintf(LOG_FILE_HANDLE, 'INTELLIGENT VOICE RECOGNITION SYSTEM\n');
        fprintf(LOG_FILE_HANDLE, 'Log rozpoczęty: %s\n', datestr(now));
        fprintf(LOG_FILE_HANDLE, '========================================\n\n');
    end
end

if ~LOG_ENABLED
    return;
end

% Formatowanie wiadomości
if nargin > 2
    formatted_message = sprintf(message, varargin{:});
else
    formatted_message = message;
end

% Timestamp
timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');

% Ikony dla różnych poziomów
switch upper(level)
    case 'DEBUG'
        icon = '🔍';
        console_color = '';
    case 'INFO'
        icon = 'ℹ️';
        console_color = '';
    case 'WARNING'
        icon = '⚠️';
        console_color = '';
    case 'ERROR'
        icon = '❌';
        console_color = '';
    case 'SUCCESS'
        icon = '✅';
        console_color = '';
    otherwise
        icon = '📝';
        console_color = '';
        level = 'INFO';
end

% Formatowanie linii log
log_line = sprintf('[%s] %s %s: %s\n', timestamp, icon, upper(level), formatted_message);

% Zapis do pliku - ZAWSZE wszystkie poziomy
if LOG_FILE_HANDLE ~= -1
    fprintf(LOG_FILE_HANDLE, '%s', log_line);
end

% Wyświetlenie w konsoli - tylko ważne komunikaty
if ismember(upper(level), {'INFO', 'WARNING', 'ERROR', 'SUCCESS'})
    fprintf('%s', log_line);
end

end