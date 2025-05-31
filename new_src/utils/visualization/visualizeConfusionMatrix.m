function visualizeConfusionMatrix(confusion_matrix, labels, title_text, save_path)
% VISUALIZECONFUSIONMATRIX Wyświetla macierz pomyłek dla klasyfikatora
%
% Składnia:
%   visualizeConfusionMatrix(confusion_matrix, labels, title_text, save_path)
%
% Argumenty:
%   confusion_matrix - macierz pomyłek [klasy × klasy]
%   labels - etykiety klas (cell array)
%   title_text - opcjonalny tekst tytułu (domyślnie 'Macierz konfuzji')
%   save_path - opcjonalna ścieżka do zapisania wykresu

% Ustawienie domyślnego tytułu
if nargin < 3
    title_text = 'Macierz konfuzji';
end

% Ustawienie domyślnej flagi zapisu
if nargin < 4
    save_path = '';
end

try
    % Utworzenie nowej figury
    h = figure('Name', title_text, 'Position', [200, 200, 800, 600]);
    
    % Obliczenie dokładności
    accuracy = sum(diag(confusion_matrix)) / sum(confusion_matrix(:));
    
    % Utworzenie wykresu
    cm = confusionchart(confusion_matrix, labels);
    cm.Title = sprintf('%s (Dokładność: %.2f%%)', title_text, accuracy * 100);
    cm.ColumnSummary = 'column-normalized';
    cm.RowSummary = 'row-normalized';
    
    % Dostosowanie kolorystyki
    colormap(parula);
    
    % Zapisanie wizualizacji jeśli podano ścieżkę
    if ~isempty(save_path)
        % Sprawdzenie czy folder istnieje, jeśli nie - utworzenie
        viz_dir = fileparts(save_path);
        if ~exist(viz_dir, 'dir')
            mkdir(viz_dir);
            logInfo('📁 Utworzono katalog dla wizualizacji: %s', viz_dir);
        end
        
        % Zapisanie figury
        saveas(h, save_path);
        logInfo('💾 Zapisano wizualizację: %s', save_path);
    end
    
catch e
    logWarning('⚠️ Problem z wyświetleniem macierzy konfuzji: %s', e.message);
    
    % Alternatywna metoda wyświetlenia jako heatmapy
    try
        h = figure('Name', title_text, 'Position', [200, 200, 800, 600]);
        imagesc(confusion_matrix);
        colorbar;
        
        % Etykiety osi
        xticks(1:length(labels));
        yticks(1:length(labels));
        xticklabels(labels);
        yticklabels(labels);
        xlabel('Przewidziana klasa');
        ylabel('Rzeczywista klasa');
        
        % Tytuł z dokładnością
        accuracy = sum(diag(confusion_matrix)) / sum(confusion_matrix(:));
        title(sprintf('%s (Dokładność: %.2f%%)', title_text, accuracy * 100));
        
        % Dodaj wartości do komórek
        for i = 1:size(confusion_matrix, 1)
            for j = 1:size(confusion_matrix, 2)
                if confusion_matrix(i, j) > 0
                    text(j, i, num2str(confusion_matrix(i, j)), ...
                        'HorizontalAlignment', 'center', ...
                        'Color', 'white');
                end
            end
        end
        
        % Zapisanie wizualizacji jeśli podano ścieżkę
        if ~isempty(save_path)
            saveas(h, save_path);
            logInfo('💾 Zapisano wizualizację: %s', save_path);
        end
    catch e2
        logError('❌ Nie można wyświetlić macierzy konfuzji: %s', e2.message);
    end
end

end