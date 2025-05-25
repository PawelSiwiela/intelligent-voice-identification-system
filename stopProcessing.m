function stopProcessing(h_fig)
if isvalid(h_fig)
    h_fig.UserData.stop_requested = true;
    
    % Zmień przycisk
    set(h_fig.UserData.stop_button, ...
        'String', '⏸️ ZATRZYMYWANIE...', ...
        'BackgroundColor', [0.7 0.7 0.3], ...
        'Enable', 'off');
    
    % Zmień status
    set(h_fig.UserData.status_text, ...
        'String', '🛑 Zatrzymywanie...');
    
    drawnow;
end
end