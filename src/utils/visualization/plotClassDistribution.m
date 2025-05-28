function plotClassDistribution(Y, labels)
% Wykres rozkładu klas

class_counts = sum(Y, 1);

figure('Name', 'Rozkład Klas', 'Position', [300, 300, 800, 500]);
bar(class_counts, 'FaceColor', [0.2 0.6 0.8]);
set(gca, 'XTickLabel', labels);
xlabel('Klasy');
ylabel('Liczba próbek');
title('Rozkład próbek per klasa');
grid on;

% Dodaj wartości na słupkach
for i = 1:length(class_counts)
    text(i, class_counts(i) + 0.5, num2str(class_counts(i)), ...
        'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end

end