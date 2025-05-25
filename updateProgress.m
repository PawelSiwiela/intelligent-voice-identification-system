function stop_requested = updateProgress(h_fig, current, total, category_name, sample_num, max_samples, successful, failed)
% =========================================================================
% AKTUALIZACJA OKNA POSTĘPU PRZETWARZANIA
% =========================================================================
% Aktualizuje wszystkie elementy okna postępu i sprawdza czy użytkownik
% zażądał zatrzymania procesu
%
% ARGUMENTY:
%   h_fig - uchwyt do okna postępu
%   current - aktualny numer próbki
%   total - całkowita liczba próbek
%   category_name - nazwa aktualnie przetwarzanej kategorii
%   sample_num - numer próbki w kategorii
%   max_samples - maksymalna liczba próbek w kategorii
%   successful - liczba udanych wczytań
%   failed - liczba nieudanych wczytań
%
% ZWRACA:
%   stop_requested - true jeśli użytkownik zażądał zatrzymania
% =========================================================================

% Inicjalizacja zwracanej wartości
stop_requested = false;

% =========================================================================
% SPRAWDZENIE POPRAWNOŚCI OKNA
% =========================================================================

% Sprawdzenie czy okno nadal istnieje
if ~isvalid(h_fig)
    stop_requested = true;
    return;
end

% Sprawdzenie czy użytkownik zażądał zatrzymania
if isfield(h_fig.UserData, 'stop_requested') && h_fig.UserData.stop_requested
    stop_requested = true;
    return;
end

% =========================================================================
% OBLICZENIA POSTĘPU
% =========================================================================

% Obliczenie procentowego postępu
percentage = (current / total) * 100;

% Obliczenie szerokości paska postępu (w pikselach)
bar_width = round(510 * current / total);

% =========================================================================
% AKTUALIZACJA PASKA POSTĘPU
% =========================================================================

% Aktualizacja szerokości paska postępu
set(h_fig.UserData.progress_bar, 'Position', [20, 170, bar_width, 20]);

% Aktualizacja tekstu procentowego
set(h_fig.UserData.percent_text, 'String', sprintf('%.1f%%', percentage));

% =========================================================================
% AKTUALIZACJA INFORMACJI STATUSU
% =========================================================================

% Aktualizacja aktualnego statusu przetwarzania
status_str = sprintf('🎯 %s | Próbka %d/%d', ...
    category_name, sample_num, max_samples);
set(h_fig.UserData.status_text, 'String', status_str);

% Aktualizacja statystyk wczytywania
if successful + failed > 0
    success_rate = 100 * successful / (successful + failed);
    stats_str = sprintf('✅ Udane: %d | ❌ Nieudane: %d | 📈 Sukces: %.1f%%', ...
        successful, failed, success_rate);
else
    stats_str = sprintf('✅ Udane: %d | ❌ Nieudane: %d', successful, failed);
end
set(h_fig.UserData.stats_text, 'String', stats_str);

% =========================================================================
% AKTUALIZACJA INFORMACJI O CZASIE
% =========================================================================

% Obliczenie czasu, który upłynął od rozpoczęcia
elapsed = toc(h_fig.UserData.start_time);

% Szacowanie czasu pozostałego (jeśli to możliwe)
if current > 0
    % Szacowanie całkowitego czasu na podstawie dotychczasowego postępu
    estimated_total = elapsed * total / current;
    remaining = estimated_total - elapsed;
    
    % Formatowanie informacji o czasie
    if remaining > 60
        time_str = sprintf('⏱️ Czas: %.1fs | 🕐 Pozostało: ~%.1f min', ...
            elapsed, remaining/60);
    else
        time_str = sprintf('⏱️ Czas: %.1fs | 🕐 Pozostało: ~%.1fs', ...
            elapsed, remaining);
    end
else
    % Na początku nie można oszacować czasu pozostałego
    time_str = sprintf('⏱️ Czas: %.1fs', elapsed);
end

set(h_fig.UserData.time_text, 'String', time_str);

% =========================================================================
% ODŚWIEŻENIE INTERFEJSU
% =========================================================================

% Odświeżenie okna z ograniczeniem częstotliwości dla wydajności
drawnow limitrate;

end