function logError(message, varargin)
% LOGERROR Zapisuje komunikat błędu
%
% Składnia:
%   logError(message, varargin)
%
% Argumenty:
%   message - treść komunikatu
%   varargin - opcjonalne parametry do formatowania wiadomości

writeLog('ERROR', message, varargin{:});
end