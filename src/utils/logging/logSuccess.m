function logSuccess(message, varargin)
% LOGSUCCESS Zapisuje komunikat o powodzeniu operacji
%
% Składnia:
%   logSuccess(message, varargin)
%
% Argumenty:
%   message - treść komunikatu
%   varargin - opcjonalne parametry do formatowania wiadomości

writeLog('SUCCESS', message, varargin{:});
end