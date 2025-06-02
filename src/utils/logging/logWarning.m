function logWarning(message, varargin)
% LOGWARNING Zapisuje ostrzeżenie
%
% Składnia:
%   logWarning(message, varargin)
%
% Argumenty:
%   message - treść komunikatu
%   varargin - opcjonalne parametry do formatowania wiadomości

writeLog('WARNING', message, varargin{:});
end