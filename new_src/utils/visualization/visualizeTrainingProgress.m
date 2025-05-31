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
%   y_pred - opcjonalnie przewidywania dla krzywej ROC
%   Y_true - opcjonalnie rzeczywiste klasy dla krzywej ROC

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
    h = figure('Name', sprintf('Postęp treningu - %s', network_name), 'Position', [200, 200, 800, 400]);
    
    % 1. Krzywe błędu w czasie
    semilogy(1:length(tr.perf), tr.perf, 'b-', 'LineWidth', 2);
    
    hold on;
    if isfield(tr, 'vperf') && ~isempty(tr.vperf)
        semilogy(1:length(tr.vperf), tr.vperf, 'r--', 'LineWidth', 2);
    end
    if isfield(tr, 'tperf') && ~isempty(tr.tperf)
        semilogy(1:length(tr.tperf), tr.tperf, 'g-.', 'LineWidth', 2);
    end
    hold off;
    
    title(sprintf('%s - Krzywe błędu (najlepsza epoka: %d)', network_name, tr.best_epoch));
    xlabel('Epoka');
    ylabel('Błąd (skala logarytmiczna)');
    grid on;
    legend({'Trening', 'Walidacja', 'Test'}, 'Location', 'best');
    
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