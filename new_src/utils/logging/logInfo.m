function logInfo(message, varargin)
% LOGINFO Zapisuje komunikat informacyjny
%
% Składnia:
%   logInfo(message, varargin)
%
% Argumenty:
%   message - treść komunikatu
%   varargin - opcjonalne parametry do formatowania wiadomości

writeLog('INFO', message, varargin{:});
end