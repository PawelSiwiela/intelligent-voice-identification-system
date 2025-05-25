function displayLoadedDataInfo(X, Y, labels, loaded_data)
% Wyświetla informacje o wczytanych danych
logSuccess('✅ Dane zostały wczytane z pliku!');
logInfo('   📊 Rozmiar macierzy X: %dx%d (próbki × cechy)', size(X,1), size(X,2));
logInfo('   🏷️ Rozmiar macierzy Y: %dx%d (próbki × kategorie)', size(Y,1), size(Y,2));
logInfo('   📂 Liczba kategorii: %d', length(labels));

if isfield(loaded_data, 'normalization_status')
    logInfo('   🔧 Status normalizacji: %s', loaded_data.normalization_status);
end
end