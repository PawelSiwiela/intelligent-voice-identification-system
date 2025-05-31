function writeLog(level, message, varargin)
% WRITELOG Zapisuje komunikat do pliku logu i wyświetla go w konsoli
%
% Składnia:
%   writeLog(level, message, varargin)
%
% Argumenty:
%   level - poziom komunikatu (DEBUG, INFO, WARNING, ERROR, SUCCESS)
%   message - treść komunikatu (może zawierać formatowanie jak w printf)
%   varargin - opcjonalne parametry do formatowania wiadomości

% Inicjalizacja globalnej zmiennej przechowującej uchwyt do pliku logu
global LOG_FILE_HANDLE;

% Formatowanie wiadomości z opcjonalnymi parametrami
if ~isempty(varargin)
    message = sprintf(message, varargin{:});
end

% Przygotowanie znacznika czasu
timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');

% Wybór ikony na podstawie poziomu
switch level
    case 'DEBUG'
        icon = '🔍';
    case 'INFO'
        icon = 'ℹ️';
    case 'WARNING'
        icon = '⚠️';
    case 'ERROR'
        icon = '❌';
    case 'SUCCESS'
        icon = '✅';
    otherwise
        icon = '';
end

% Pełny komunikat z datą i poziomem
full_message = sprintf('%s [%s] %s %s', timestamp, level, icon, message);

% Wyświetl komunikat w konsoli MATLAB
fprintf('%s\n', full_message);

% Jeśli uchwyt do pliku nie istnieje, spróbuj go utworzyć
if isempty(LOG_FILE_HANDLE) || LOG_FILE_HANDLE == -1
    try
        % Utwórz folder output/logs w głównym katalogu projektu, jeśli nie istnieje
        log_dir = fullfile('output', 'logs');
        if ~exist(log_dir, 'dir')
            mkdir(log_dir);
        end
        
        % Przygotuj nazwę pliku logu na podstawie daty
        log_filename = fullfile(log_dir, sprintf('log_%s.txt', datestr(now, 'yyyymmdd_HHMMSS')));
        
        % Otwórz plik do zapisu (append)
        LOG_FILE_HANDLE = fopen(log_filename, 'a');
        
        % Jeśli to nowy plik, dodaj nagłówek
        if LOG_FILE_HANDLE ~= -1 && ftell(LOG_FILE_HANDLE) == 0
            fprintf(LOG_FILE_HANDLE, '========================================\n');
            fprintf(LOG_FILE_HANDLE, 'INTELLIGENT VOICE IDENTIFICATION SYSTEM\n');
            fprintf(LOG_FILE_HANDLE, 'Log rozpoczęty: %s\n', datestr(now));
            fprintf(LOG_FILE_HANDLE, '========================================\n\n');
        end
    catch
        % W przypadku błędu, ustaw pusty uchwyt
        LOG_FILE_HANDLE = -1;
        fprintf('❌ Nie można otworzyć pliku logu!\n');
    end
end

% Zapisz komunikat do pliku, jeśli jest otwarty
if LOG_FILE_HANDLE ~= -1
    try
        fprintf(LOG_FILE_HANDLE, '%s\n', full_message);
    catch
        LOG_FILE_HANDLE = -1;
        fprintf('❌ Błąd podczas zapisu do pliku logu!\n');
    end
end

end