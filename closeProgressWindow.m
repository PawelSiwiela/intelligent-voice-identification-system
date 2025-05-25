function closeProgressWindow(h_fig)
if isvalid(h_fig)
    choice = questdlg('Czy na pewno chcesz zatrzymać przetwarzanie?', ...
        'Potwierdzenie zatrzymania', ...
        'Tak', 'Nie', 'Nie');
    
    if strcmp(choice, 'Tak')
        h_fig.UserData.stop_requested = true;
        set(h_fig.UserData.status_text, ...
            'String', '🛑 Zatrzymywanie procesu przetwarzania...');
        drawnow;
        % Nie zamykaj okna jeszcze - niech to zrobi główna pętla
    end
end
end