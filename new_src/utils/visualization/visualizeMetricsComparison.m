function visualizeMetricsComparison(metrics1, metrics2, network1_name, network2_name, save_path)
% VISUALIZEMETRICSCOMPARISON Porównuje wizualnie metryki dwóch sieci
%
% Składnia:
%   visualizeMetricsComparison(metrics1, metrics2, network1_name, network2_name, save_path)
%
% Argumenty:
%   metrics1 - struktura metryk pierwszej sieci
%   metrics2 - struktura metryk drugiej sieci
%   network1_name - nazwa pierwszej sieci (np. 'patternnet')
%   network2_name - nazwa drugiej sieci (np. 'feedforwardnet')
%   save_path - opcjonalna ścieżka do zapisu wykresu

% Sprawdzanie poprawności argumentów wejściowych
if nargin < 3
    network1_name = 'Sieć 1';
    network2_name = 'Sieć 2';
elseif nargin < 4
    network2_name = 'Sieć 2';
end

% Domyślnie brak zapisu
if nargin < 5
    save_path = '';
end

try
    % Definiowanie głównych metryk do porównania
    metric_names = {'Dokładność', 'Precyzja', 'Czułość', 'F1-Score', 'Czas predykcji (ms)'};
    
    % Przygotowanie danych do wyświetlenia
    values1 = [
        metrics1.accuracy,
        metrics1.macro_precision,
        metrics1.macro_recall,
        metrics1.macro_f1,
        metrics1.prediction_time * 1000  % Konwersja na milisekundy
        ];
    
    values2 = [
        metrics2.accuracy,
        metrics2.macro_precision,
        metrics2.macro_recall,
        metrics2.macro_f1,
        metrics2.prediction_time * 1000  % Konwersja na milisekundy
        ];
    
    % Pierwszy wykres: porównanie dokładności, precyzji, czułości i F1
    h = figure('Name', 'Porównanie metryk', 'Position', [100, 100, 1000, 500]);
    
    % Lewy wykres: Metryki klasyfikacji (jako procenty)
    subplot(1, 2, 1);
    bar([values1(1:4); values2(1:4)]' * 100);  % Konwersja na procenty
    
    title('Porównanie metryk klasyfikacji');
    xlabel('Metryka');
    ylabel('Wartość (%)');
    set(gca, 'XTickLabel', metric_names(1:4));
    legend({network1_name, network2_name});
    grid on;
    
    % Dodanie etykiet wartości nad słupkami
    for i = 1:4
        x = i - 0.15;
        y = values1(i) * 100 + 1;
        text(x, y, sprintf('%.1f%%', values1(i)*100), 'HorizontalAlignment', 'center');
        
        x = i + 0.15;
        y = values2(i) * 100 + 1;
        text(x, y, sprintf('%.1f%%', values2(i)*100), 'HorizontalAlignment', 'center');
    end
    
    % Prawy wykres: Czas predykcji
    subplot(1, 2, 2);
    bar([values1(5), values2(5)]);
    
    title('Czas predykcji');
    xlabel('Sieć');
    ylabel('Czas (ms)');
    set(gca, 'XTickLabel', {network1_name, network2_name});
    grid on;
    
    % Dodanie etykiet wartości nad słupkami
    text(1, values1(5) + max([values1(5), values2(5)])*0.05, ...
        sprintf('%.2f ms', values1(5)), 'HorizontalAlignment', 'center');
    
    text(2, values2(5) + max([values1(5), values2(5)])*0.05, ...
        sprintf('%.2f ms', values2(5)), 'HorizontalAlignment', 'center');
    
    % Zapisanie wizualizacji jeśli podano ścieżkę
    if ~isempty(save_path)
        % Sprawdzenie czy folder istnieje, jeśli nie - utworzenie
        viz_dir = fileparts(save_path);
        if ~exist(viz_dir, 'dir')
            mkdir(viz_dir);
            fprintf('📁 Utworzono katalog dla wizualizacji: %s\n', viz_dir);
        end
        
        % Zapisanie figury
        saveas(h, save_path);
        fprintf('💾 Zapisano wizualizację metryk do: %s\n', save_path);
    end
    
catch e
    fprintf('❌ Błąd podczas generowania wizualizacji metryk: %s\n', e.message);
end

end