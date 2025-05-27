function stopProcessing(h_fig)
% =========================================================================
% OBSŁUGA ZATRZYMANIA PROCESU PRZETWARZANIA
% =========================================================================
% Funkcja wywoływana gdy użytkownik kliknie przycisk "ZATRZYMAJ"
% Ustawia flagę zatrzymania i aktualizuje interfejs użytkownika
%
% ARGUMENTY:
%   h_fig - uchwyt do okna postępu
% =========================================================================

% Sprawdzenie czy okno nadal istnieje
if isvalid(h_fig)
    % =====================================================================
    % USTAWIENIE FLAGI ZATRZYMANIA
    % =====================================================================
    
    % Ustawienie flagi informującej o żądaniu zatrzymania
    h_fig.UserData.stop_requested = true;
    
    % =====================================================================
    % AKTUALIZACJA INTERFEJSU UŻYTKOWNIKA
    % =====================================================================
    
    % Zmiana wyglądu przycisku na "zatrzymywanie"
    set(h_fig.UserData.stop_button, ...
        'String', '⏸️ ZATRZYMYWANIE...', ...      % Nowy tekst
        'BackgroundColor', [0.7 0.7 0.3], ...     % Żółte tło
        'Enable', 'off');                         % Wyłączenie przycisku
    
    % Aktualizacja statusu przetwarzania
    set(h_fig.UserData.status_text, ...
        'String', '🛑 Zatrzymywanie procesu...');
    
    % Natychmiastowe odświeżenie interfejsu
    drawnow;
    
    % Informacja w konsoli
    fprintf('\n⚠️ Użytkownik zażądał zatrzymania procesu przetwarzania...\n');
end

end
