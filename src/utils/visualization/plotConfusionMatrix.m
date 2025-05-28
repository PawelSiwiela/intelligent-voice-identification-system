function plotConfusionMatrix(true_labels, predicted_labels, class_names, title_text)
% Tworzy i wyświetla macierz konfuzji

figure('Name', 'Macierz Konfuzji', 'Position', [100, 100, 800, 600]);

% Obliczenie macierzy konfuzji
C = confusionmat(true_labels, predicted_labels);

% Normalizacja do procentów
C_norm = C ./ sum(C, 2) * 100;

% Wyświetlenie heatmapy
imagesc(C_norm);
colormap(flipud(gray));
colorbar;

% Dodanie tekstu z wartościami
[rows, cols] = size(C);
for i = 1:rows
    for j = 1:cols
        text(j, i, sprintf('%d\n(%.1f%%)', C(i,j), C_norm(i,j)), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 10, 'FontWeight', 'bold');
    end
end

% Ustawienia osi
set(gca, 'XTick', 1:length(class_names), 'XTickLabel', class_names);
set(gca, 'YTick', 1:length(class_names), 'YTickLabel', class_names);
xlabel('Przewidywane klasy');
ylabel('Rzeczywiste klasy');
title(title_text);
grid on;

end