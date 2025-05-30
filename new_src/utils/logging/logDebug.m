function logDebug(message, varargin)
% LOGDEBUG Zapisuje komunikat debugowania
%
% Składnia:
%   logDebug(message, varargin)
%
% Argumenty:
%   message - treść komunikatu
%   varargin - opcjonalne parametry do formatowania wiadomości

writeLog('DEBUG', message, varargin{:});
end