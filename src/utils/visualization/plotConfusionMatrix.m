function plotConfusionMatrix(true_labels, predicted_labels, class_names, title_text)
% PLOTCONFUSIONMATRIX Wyświetla macierz konfuzji
%
% PARAMETRY:
%   true_labels      - Rzeczywiste etykiety klas (wektor)
%   predicted_labels - Przewidywane etykiety klas (wektor)
%   class_names      - Nazwy klas (cell array)
%   title_text       - Tytuł wykresu (string)

% ===== OBLICZENIE MACIERZY KONFUZJI =====
C = confusionmat(true_labels, predicted_labels);
num_classes = length(class_names);

% Normalizacja do procentów (per wiersz)
C_norm = C ./ sum(C, 2) * 100;

% Obliczenie ogólnej accuracy
overall_accuracy = sum(diag(C)) / sum(C(:)) * 100;

% ===== TWORZENIE WYKRESU =====
figure('Name', 'Macierz Konfuzji', 'Position', [100, 100, 900, 700]);

% Heatmapa w skali szarości
imagesc(C_norm);
colormap(flipud(gray));
colorbar;

% Dodanie siatki dla lepszej czytelności
hold on;
for i = 1.5:num_classes-0.5
    plot([i i], [0.5 num_classes+0.5], 'k-', 'LineWidth', 0.5);
    plot([0.5 num_classes+0.5], [i i], 'k-', 'LineWidth', 0.5);
end
hold off;

% ===== DODANIE WARTOŚCI W KOMÓRKACH =====
for i = 1:num_classes
    for j = 1:num_classes
        % Kolor tekstu zależny od jasności tła
        if C_norm(i,j) > 50
            text_color = 'white';
        else
            text_color = 'black';
        end
        
        % Wyświetlenie liczby i procentu
        text(j, i, sprintf('%d', C(i,j)), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
            'FontSize', 11, 'FontWeight', 'bold', 'Color', text_color);
    end
end

% ===== USTAWIENIA OSI =====
set(gca, 'XTick', 1:num_classes);
set(gca, 'XTickLabel', class_names);
set(gca, 'XTickLabelRotation', 45);
set(gca, 'YTick', 1:num_classes);
set(gca, 'YTickLabel', class_names);
xlabel('Przewidywane klasy', 'FontWeight', 'bold');
ylabel('Rzeczywiste klasy', 'FontWeight', 'bold');

% Własny tytuł z dokładnością
title_with_accuracy = sprintf('Macierz Konfuzji - skuteczność: %.1f%%', overall_accuracy);
title(title_with_accuracy, 'FontWeight', 'bold', 'FontSize', 12);

% ===== LOGOWANIE =====
if exist('logSuccess', 'file') == 2
    logSuccess('🎯 Macierz konfuzji wyświetlona (Accuracy: %.1f%%)', overall_accuracy);
else
    fprintf('🎯 Macierz konfuzji wyświetlona\n');
end

end