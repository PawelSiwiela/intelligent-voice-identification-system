function displayLoadedDataInfo(X, Y, labels, loaded_data)
% Wyświetla informacje o wczytanych danych
fprintf('✅ Dane zostały wczytane z pliku!\n');
fprintf('   📊 Rozmiar macierzy X: %dx%d (próbki × cechy)\n', size(X,1), size(X,2));
fprintf('   🏷️ Rozmiar macierzy Y: %dx%d (próbki × kategorie)\n', size(Y,1), size(Y,2));
fprintf('   📂 Liczba kategorii: %d\n', length(labels));

if isfield(loaded_data, 'normalization_status')
    fprintf('   🔧 Status normalizacji: %s\n', loaded_data.normalization_status);
end
end