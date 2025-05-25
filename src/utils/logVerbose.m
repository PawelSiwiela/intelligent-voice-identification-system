function logVerbose(message, varargin)
% Komunikat verbose (tylko w pliku, nie w konsoli)
global VERBOSE_LOGGING;

if isempty(VERBOSE_LOGGING)
    VERBOSE_LOGGING = false; % Domyślnie wyłączone
end

if VERBOSE_LOGGING
    writeLog('DEBUG', message, varargin{:});
end
end