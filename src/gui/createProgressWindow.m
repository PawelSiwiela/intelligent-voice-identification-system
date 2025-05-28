function h_fig = createProgressWindow(total_samples, expected_categories)
% =========================================================================
% TWORZENIE OKNA POSTĘPU PRZETWARZANIA
% =========================================================================
% Tworzy graficzne okno pokazujące postęp przetwarzania danych audio
% z możliwością zatrzymania procesu przez użytkownika
%
% ARGUMENTY:
%   total_samples - całkowita liczba próbek do przetworzenia
%   expected_categories - liczba kategorii danych
%
% ZWRACA:
%   h_fig - uchwyt do okna figure
%
% FUNKCJONALNOŚCI:
%   • Pasek postępu z procentami
%   • Wyświetlanie aktualnego statusu przetwarzania
%   • Statystyki udanych/nieudanych wczytań
%   • Szacowany czas pozostały
%   • Przycisk zatrzymania procesu
% =========================================================================

% =========================================================================
% TWORZENIE GŁÓWNEGO OKNA
% =========================================================================

h_fig = figure('Name', '🎵 System Rozpoznawania Głosu', ...
    'Position', [300, 400, 550, 280], ...    % Pozycja i rozmiar okna
    'MenuBar', 'none', ...                   % Bez paska menu
    'ToolBar', 'none', ...                   % Bez paska narzędzi
    'Resize', 'off', ...                     % Brak możliwości zmiany rozmiaru
    'NumberTitle', 'off', ...                % Bez numeru w tytule
    'Color', [0.94 0.94 0.94], ...          % Jasnoszare tło
    'CloseRequestFcn', @(src,evt) closeProgressWindow(src)); % Niestandardowe zamknięcie

% Inicjalizacja flagi zatrzymania
h_fig.UserData.stop_requested = false;

% =========================================================================
% ELEMENTY INTERFEJSU UŻYTKOWNIKA
% =========================================================================

% Tytuł główny
uicontrol('Style', 'text', ...
    'String', '🎵 Przetwarzanie Danych Audio', ...
    'Position', [20, 230, 510, 30], ...
    'FontSize', 16, ...
    'FontWeight', 'bold', ...
    'BackgroundColor', [0.94 0.94 0.94], ...
    'ForegroundColor', [0.2 0.2 0.6]);

% Informacje o zadaniu
uicontrol('Style', 'text', ...
    'String', sprintf('📊 Kategorii: %d | Próbek: %d', expected_categories, total_samples), ...
    'Position', [20, 200, 510, 20], ...
    'FontSize', 11, ...
    'BackgroundColor', [0.94 0.94 0.94]);

% =========================================================================
% PASEK POSTĘPU
% =========================================================================

% Tło paska postępu
uicontrol('Style', 'text', ...
    'Position', [20, 170, 510, 20], ...
    'BackgroundColor', [0.8 0.8 0.8]);

% Aktualny pasek postępu (początkowo pusty)
h_fig.UserData.progress_bar = uicontrol('Style', 'text', ...
    'Position', [20, 170, 1, 20], ...       % Szerokość 1 piksel na początku
    'BackgroundColor', [0.2 0.7 0.2]);      % Zielony kolor

% Tekst procentowy na pasku postępu
h_fig.UserData.percent_text = uicontrol('Style', 'text', ...
    'String', '0.0%', ...
    'Position', [20, 170, 510, 20], ...
    'FontSize', 10, ...
    'FontWeight', 'bold', ...
    'BackgroundColor', 'none');

% =========================================================================
% INFORMACJE STATUSU
% =========================================================================

% Aktualny status przetwarzania
h_fig.UserData.status_text = uicontrol('Style', 'text', ...
    'String', '🔄 Przygotowanie...', ...
    'Position', [20, 140, 510, 20], ...
    'FontSize', 11, ...
    'BackgroundColor', [0.94 0.94 0.94], ...
    'HorizontalAlignment', 'left');

% Statystyki wczytywania
h_fig.UserData.stats_text = uicontrol('Style', 'text', ...
    'String', '✅ Udane: 0 | ❌ Nieudane: 0', ...
    'Position', [20, 110, 510, 20], ...
    'FontSize', 10, ...
    'BackgroundColor', [0.94 0.94 0.94], ...
    'HorizontalAlignment', 'left');

% Informacje o czasie
h_fig.UserData.time_text = uicontrol('Style', 'text', ...
    'String', '⏱️ Czas: 0s', ...
    'Position', [20, 80, 510, 20], ...
    'FontSize', 10, ...
    'BackgroundColor', [0.94 0.94 0.94], ...
    'HorizontalAlignment', 'left');

% =========================================================================
% PRZYCISK ZATRZYMANIA
% =========================================================================

h_fig.UserData.stop_button = uicontrol('Style', 'pushbutton', ...
    'String', '⏹️ ZATRZYMAJ', ...
    'Position', [200, 30, 150, 35], ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'BackgroundColor', [0.9 0.3 0.3], ...   % Czerwone tło
    'ForegroundColor', [1 1 1], ...         % Biały tekst
    'Callback', @(src,evt) stopProcessing(h_fig));

% =========================================================================
% INICJALIZACJA CZASOMIERZA
% =========================================================================

% Zapisanie czasu rozpoczęcia dla pomiarów czasu wykonania
h_fig.UserData.start_time = tic;

% Odświeżenie okna
drawnow;

end
