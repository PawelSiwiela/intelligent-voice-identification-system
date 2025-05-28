function [XTrain, YTrain, XVal, YVal] = prepareDataForAdam(X, Y, train_ratio)
% =========================================================================
% PRZYGOTOWANIE DANYCH DLA DEEP LEARNING TOOLBOX
% =========================================================================

% Podział na train/validation
num_samples = size(X, 1);
train_size = round(num_samples * train_ratio);

% Losowe indeksy
indices = randperm(num_samples);
train_indices = indices(1:train_size);
val_indices = indices(train_size+1:end);

% Podział danych
XTrain = X(train_indices, :);
XVal = X(val_indices, :);

% Konwersja Y (one-hot) do categorical
[~, train_labels] = max(Y(train_indices, :), [], 2);
[~, val_labels] = max(Y(val_indices, :), [], 2);

YTrain = categorical(train_labels);
YVal = categorical(val_labels);

logDebug('📊 Podział danych: Train=%d, Val=%d', length(YTrain), length(YVal));

end