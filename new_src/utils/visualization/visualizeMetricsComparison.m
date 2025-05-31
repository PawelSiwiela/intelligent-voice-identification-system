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
    metric_names = {'Dokładność', 'Precyzja', 'Czułość', 'F1-Score'};
    
    % Przygotowanie danych do wyświetlenia
    values1 = [
        metrics1.accuracy,
        metrics1.macro_precision,
        metrics1.macro_recall,
        metrics1.macro_f1
        ];
    
    values2 = [
        metrics2.accuracy,
        metrics2.macro_precision,
        metrics2.macro_recall,
        metrics2.macro_f1
        ];
    
    % Utworzenie figury
    h = figure('Name', 'Porównanie metryk', 'Position', [100, 100, 1000, 600]);
    
    % Kolory dla słupków
    color1 = [0.2, 0.6, 0.8];  % Niebieski dla pierwszej sieci
    color2 = [0.8, 0.4, 0.2];  % Pomarańczowy dla drugiej sieci
    
    % SUBPLOT 1: Metryki dla pierwszej sieci
    subplot(1, 2, 1);
    b1 = bar(values1' * 100, 'FaceColor', color1);
    title(sprintf('Metryki dla %s', network1_name), 'FontSize', 13);
    ylabel('Wartość (%)', 'FontSize', 12);
    set(gca, 'XTickLabel', metric_names, 'FontSize', 11, 'XTickLabelRotation', 0);
    grid on;
    ylim([0, 100]);  % Skala od 0 do 100%
    
    % Dodanie etykiet wartości nad słupkami dla pierwszej sieci
    for i = 1:length(values1)
        text(i, values1(i) * 100 + 2, sprintf('%.1f%%', values1(i) * 100), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontWeight', 'bold');
    end
    
    % SUBPLOT 2: Metryki dla drugiej sieci
    subplot(1, 2, 2);
    b2 = bar(values2' * 100, 'FaceColor', color2);
    title(sprintf('Metryki dla %s', network2_name), 'FontSize', 13);
    ylabel('Wartość (%)', 'FontSize', 12);
    set(gca, 'XTickLabel', metric_names, 'FontSize', 11, 'XTickLabelRotation', 0);
    grid on;
    ylim([0, 100]);  % Skala od 0 do 100%
    
    % Dodanie etykiet wartości nad słupkami dla drugiej sieci
    for i = 1:length(values2)
        text(i, values2(i) * 100 + 2, sprintf('%.1f%%', values2(i) * 100), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontWeight', 'bold');
    end
    
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
        logInfo('💾 Zapisano wizualizację metryk do: %s', save_path);
    end
    
catch e
    logWarning('❌ Błąd podczas generowania wizualizacji metryk: %s', e.message);
    
    % Awaryjne wyświetlanie danych tekstowo
    fprintf('=== PORÓWNANIE METRYK ===\n');
    fprintf('                 %s        %s\n', network1_name, network2_name);
    fprintf('Dokładność:      %.2f%%      %.2f%%\n', metrics1.accuracy*100, metrics2.accuracy*100);
    fprintf('Precyzja:        %.2f%%      %.2f%%\n', metrics1.macro_precision*100, metrics2.macro_precision*100);
    fprintf('Czułość:         %.2f%%      %.2f%%\n', metrics1.macro_recall*100, metrics2.macro_recall*100);
    fprintf('F1-Score:        %.2f%%      %.2f%%\n', metrics1.macro_f1*100, metrics2.macro_f1*100);
    fprintf('Czas predykcji:  %.2fms      %.2fms\n', metrics1.prediction_time*1000, metrics2.prediction_time*1000);
end

end