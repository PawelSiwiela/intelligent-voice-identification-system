function accuracy = calculateAccuracy(Y_pred, Y_true)
% =========================================================================
% OBLICZENIE ACCURACY Z MACIERZY PREDYKCJI I PRAWDZIWYCH ETYKIET
% =========================================================================

% Konwersja z one-hot do klas
if size(Y_pred, 1) > 1
    [~, predicted_classes] = max(Y_pred, [], 1);
    [~, true_classes] = max(Y_true, [], 1);
else
    [~, predicted_classes] = max(Y_pred, [], 2);
    [~, true_classes] = max(Y_true, [], 2);
end

% Obliczenie accuracy
accuracy = sum(predicted_classes == true_classes) / length(true_classes);

end