function [net, accuracy] = trainWithAdam(XTrain, YTrain, XVal, YVal, params)
% =========================================================================
% TRENOWANIE SIECI Z ALGORYTMEM ADAM
% =========================================================================

% Tworzenie architektury sieci
layers = [
    featureInputLayer(size(XTrain, 2))
    ];

% Dodawanie warstw ukrytych
for i = 1:length(params.hidden_layers)
    layers = [layers
        fullyConnectedLayer(params.hidden_layers(i))
        reluLayer
        dropoutLayer(params.dropout_rate)
        ];
end

% Warstwa wyjściowa
layers = [layers
    fullyConnectedLayer(size(YTrain, 2))
    softmaxLayer
    classificationLayer
    ];

% Opcje treningu z ADAM
options = trainingOptions('adam', ...
    'InitialLearnRate', params.learning_rate, ...
    'GradientDecayFactor', params.beta1, ...
    'SquaredGradientDecayFactor', params.beta2, ...
    'Epsilon', params.epsilon, ...
    'MaxEpochs', params.epochs, ...
    'MiniBatchSize', params.batch_size, ...
    'ValidationData', {XVal, YVal}, ...
    'ValidationFrequency', 10, ...
    'Verbose', false, ...
    'Plots', 'none');

% Trenowanie sieci
net = trainNetwork(XTrain, YTrain, layers, options);

% Ewaluacja na zbiorze walidacyjnym
YPred = classify(net, XVal);
accuracy = sum(YPred == YVal) / numel(YVal);

end