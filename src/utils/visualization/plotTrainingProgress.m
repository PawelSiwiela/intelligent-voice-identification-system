function plotTrainingProgress(net, title_text)
% Wyświetla krzywe konwergencji trenowania

if isfield(net.trainParam, 'tr') && ~isempty(net.trainParam.tr)
    tr = net.trainParam.tr;
    
    figure('Name', 'Konwergencja Trenowania', 'Position', [200, 200, 1000, 400]);
    
    % Subplot 1: Performance
    subplot(1, 2, 1);
    semilogy(tr.epoch, tr.perf, 'b-', 'LineWidth', 2);
    if ~isempty(tr.vperf)
        hold on;
        semilogy(tr.epoch, tr.vperf, 'r--', 'LineWidth', 2);
        legend('Training', 'Validation', 'Location', 'best');
    end
    xlabel('Epoka');
    ylabel('Performance (MSE)');
    title('Krzywa uczenia');
    grid on;
    
    % Subplot 2: Gradient
    subplot(1, 2, 2);
    semilogy(tr.epoch, tr.gradient, 'g-', 'LineWidth', 2);
    xlabel('Epoka');
    ylabel('Gradient');
    title('Zbieżność gradientu');
    grid on;
    
    sgtitle(title_text);
end

end