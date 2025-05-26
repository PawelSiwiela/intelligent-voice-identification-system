function indices = crossvalind(method, N, k)
% =========================================================================
% CROSS-VALIDATION INDICES GENERATOR
% =========================================================================
% Tworzy indeksy dla k-fold cross-validation
% AUTOR: Paweł Siwiela, 2025
% =========================================================================

if strcmpi(method, 'Kfold')
    % K-fold cross-validation
    indices = zeros(N, 1);
    
    % Obliczenie rozmiaru każdego foldu
    fold_size = floor(N / k);
    remainder = mod(N, k);
    
    idx = 1;
    for fold = 1:k
        if fold <= remainder
            current_fold_size = fold_size + 1;
        else
            current_fold_size = fold_size;
        end
        
        % Przypisanie indeksów do aktualnego foldu
        for i = 1:current_fold_size
            if idx <= N
                indices(idx) = fold;
                idx = idx + 1;
            end
        end
    end
    
    % Losowe permutowanie indeksów
    random_order = randperm(N);
    indices = indices(random_order);
    
else
    error('Nieobsługiwana metoda: %s', method);
end

logDebug('🔀 Utworzono indeksy CV: %d próbek w %d folds', N, k);

end