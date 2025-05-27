function closeProgressWindow(h_fig)
% =========================================================================
% OBSŁUGA ZAMKNIĘCIA OKNA POSTĘPU
% =========================================================================
% Funkcja wywoływana gdy użytkownik próbuje zamknąć okno postępu (kliknięcie X)
% Wyświetla okno potwierdzenia przed zatrzymaniem procesu
%
% ARGUMENTY:
%   h_fig - uchwyt do okna postępu
% =========================================================================

% Sprawdzenie czy okno nadal istnieje
if isvalid(h_fig)
    % =====================================================================
    % OKNO POTWIERDZENIA
    % =====================================================================
    
    % Wyświetlenie okna dialogowego z pytaniem o potwierdzenie
    choice = questdlg(...
        'Czy na pewno chcesz zatrzymać przetwarzanie danych audio?', ...
        'Potwierdzenie zatrzymania', ...
        'Tak', 'Nie', 'Nie');  % Opcje: Tak, Nie (domyślnie Nie)
    
    % =====================================================================
    % OBSŁUGA WYBORU UŻYTKOWNIKA
    % =====================================================================
    
    if strcmp(choice, 'Tak')
        % Użytkownik potwierdził zatrzymanie
        fprintf('\n🛑 Użytkownik potwierdził zatrzymanie procesu przez zamknięcie okna.\n');
        
        % Ustawienie flagi zatrzymania
        h_fig.UserData.stop_requested = true;
        
        % Aktualizacja statusu w oknie
        set(h_fig.UserData.status_text, ...
            'String', '🛑 Zatrzymywanie procesu przetwarzania...');
        
        % Aktualizacja przycisku zatrzymania
        if isfield(h_fig.UserData, 'stop_button') && isvalid(h_fig.UserData.stop_button)
            set(h_fig.UserData.stop_button, ...
                'String', '⏸️ ZATRZYMYWANIE...', ...
                'BackgroundColor', [0.7 0.7 0.3], ...
                'Enable', 'off');
        end
        
        % Odświeżenie interfejsu
        drawnow;
        
        % UWAGA: Nie zamykamy okna tutaj - pozwalamy głównej pętli
        % przetwarzania na czyste zakończenie i zamknięcie okna
        
    else
        % Użytkownik anulował zatrzymanie
        fprintf('ℹ️ Użytkownik anulował zatrzymanie - kontynuowanie przetwarzania.\n');
        
        % Nie robimy nic - proces przetwarzania jest kontynuowany
    end
end

end
