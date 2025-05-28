function results = testFinalNetwork(net, X, Y, labels, golden_params)
% KOMPLEKSOWE TESTOWANIE FINALNEJ SIECI Z WIZUALIZACJĄ

logInfo('🧪 ROZPOCZYNAM FINALNE TESTOWANIE SIECI...');

% ===== PODSTAWOWE PREDYKCJE =====
outputs = net(X');
[~, predicted_classes] = max(outputs, [], 1);
[~, true_classes] = max(Y', [], 1);

% ===== METRYKI PODSTAWOWE =====
accuracy = sum(predicted_classes == true_classes) / length(true_classes);
logSuccess('🎯 Finalna accuracy: %.2f%%', accuracy * 100);

% ===== METRYKI PER KLASA =====
num_classes = size(Y, 2);
class_metrics = calculateDetailedMetrics(true_classes, predicted_classes, num_classes);

% ===== ŚREDNIE METRYKI - PROSTE I JASNE =====
if ~isempty(class_metrics)
    avg_precision = mean([class_metrics.precision]);
    avg_recall = mean([class_metrics.recall]);
    avg_f1 = mean([class_metrics.f1_score]);
    
    logInfo('📈 ŚREDNIE METRYKI:');
    logInfo('   Precision: %.3f', avg_precision);
    logInfo('   Recall: %.3f', avg_recall);
    logInfo('   F1-Score: %.3f', avg_f1);
end

% ===== RETURN RESULTS =====
results = struct();
results.accuracy = accuracy;
results.class_metrics = class_metrics;
results.predictions = predicted_classes;
results.true_labels = true_classes;

logSuccess('✅ Finalne testowanie zakończone!');

end

function class_metrics = calculateDetailedMetrics(true_classes, predicted_classes, num_classes)
% Oblicza szczegółowe metryki per klasa

class_metrics = struct();
for class = 1:num_classes
    tp = sum((predicted_classes == class) & (true_classes == class));
    fp = sum((predicted_classes == class) & (true_classes ~= class));
    fn = sum((predicted_classes ~= class) & (true_classes == class));
    tn = sum((predicted_classes ~= class) & (true_classes ~= class));
    
    % Podstawowe metryki
    class_metrics(class).precision = tp / (tp + fp + eps);
    class_metrics(class).recall = tp / (tp + fn + eps);
    class_metrics(class).f1_score = 2 * class_metrics(class).precision * class_metrics(class).recall / ...
        (class_metrics(class).precision + class_metrics(class).recall + eps);
    class_metrics(class).accuracy = (tp + tn) / (tp + fp + fn + tn);
end

end