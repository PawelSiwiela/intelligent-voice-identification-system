function visualizeTrainingProgress(tr, network_name, save_path)
% VISUALIZETRAININGPROGRESS Wizualizacja postępu treningu sieci
%
% Składnia:
%   visualizeTrainingProgress(tr, network_name, save_path)
%
% Argumenty:
%   tr - dane treningowe zwrócone przez funkcję train
%   network_name - opcjonalna nazwa sieci (domyślnie 'Sieć neuronowa')
%   save_path - opcjonalna ścieżka do zapisu wykresu

% Domyślna nazwa sieci
if nargin < 2
    network_name = 'Sieć neuronowa';
end

% Domyślnie brak zapisu
if nargin < 3
    save_path = '';
end

try
    % Utworzenie figury z unikalnym uchwytem
    h = figure('Name', sprintf('Postęp treningu - %s', network_name), 'Position', [200, 200, 1000, 700]);
    
    % Układ 2x2 dla różnych wizualizacji
    
    % 1. Błędy treningowe w czasie
    subplot(2, 2, 1);
    epochs = 1:length(tr.perf);
    semilogy(epochs, tr.perf, 'b-', 'LineWidth', 2);
    
    hold on;
    if ~isempty(tr.vperf)
        semilogy(epochs, tr.vperf, 'r--', 'LineWidth', 2);
    end
    if ~isempty(tr.tperf)
        semilogy(epochs, tr.tperf, 'g-.', 'LineWidth', 2);
    end
    hold off;
    
    title('Krzywe błędu');
    xlabel('Epoka');
    ylabel('Błąd (log)');
    grid on;
    legend({'Trening', 'Walidacja', 'Test'}, 'Location', 'best');
    
    % 2. Gradient i mu (dla algorytmów Levenberga-Marquardta)
    subplot(2, 2, 2);
    if isfield(tr, 'grad')
        yyaxis left;
        semilogy(epochs, tr.grad, 'b-', 'LineWidth', 2);
        ylabel('Gradient');
        
        if isfield(tr, 'mu')
            yyaxis right;
            semilogy(epochs, tr.mu, 'r-', 'LineWidth', 2);
            ylabel('mu');
        end
        
        title('Gradient i parametr mu');
        xlabel('Epoka');
        grid on;
    else
        text(0.5, 0.5, 'Brak danych o gradiencie', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 12);
        axis off;
    end
    
    % 3. Liczba niepowodzeń walidacji
    subplot(2, 2, 3);
    if isfield(tr, 'val_fail')
        plot(epochs, tr.val_fail, 'm-', 'LineWidth', 2);
        title('Niepowodzenia walidacji');
        xlabel('Epoka');
        ylabel('Liczba niepowodzeń');
        grid on;
    else
        text(0.5, 0.5, 'Brak danych o niepowodzeniach walidacji', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 12);
        axis off;
    end
    
    % 4. Tempo uczenia (jeśli dostępne)
    subplot(2, 2, 4);
    if isfield(tr, 'lr')
        plot(epochs, tr.lr, 'g-', 'LineWidth', 2);
        title('Tempo uczenia');
        xlabel('Epoka');
        ylabel('Współczynnik uczenia');
        grid on;
    else
        text(0.5, 0.5, 'Brak danych o tempie uczenia', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 12);
        axis off;
    end
    
    % Dodanie ogólnych informacji
    annotation('textbox', [0.05, 0.95, 0.9, 0.05], ...
        'String', sprintf('%s - Najlepsza epoka: %d', network_name, tr.best_epoch), ...
        'FontSize', 12, ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'EdgeColor', 'none');
    
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
        fprintf('💾 Zapisano wizualizację treningu do: %s\n', save_path);
    end
    
catch e
    fprintf('❌ Błąd podczas generowania wizualizacji treningu: %s\n', e.message);
end

end