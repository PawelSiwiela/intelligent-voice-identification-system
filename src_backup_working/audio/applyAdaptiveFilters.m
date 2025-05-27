function [filtered_signal, mse_improvement] = applyAdaptiveFilters(noisy_signal, original_signal)
% =========================================================================
% ZASTOSOWANIE FILTRÓW ADAPTACYJNYCH DO SYGNAŁU AUDIO
% =========================================================================
% Funkcja stosuje trzy rodzaje filtrów adaptacyjnych (LMS, NLMS, RLS)
% do zaszumionego sygnału i wybiera najlepszy wynik na podstawie MSE
%
% ARGUMENTY:
%   noisy_signal - sygnał wejściowy z dodanym szumem
%   original_signal - oryginalny sygnał bez szumu (dla porównania)
%
% ZWRACA:
%   filtered_signal - przefiltrowany sygnał (najlepszy z trzech metod)
%   mse_improvement - wartość MSE dla wybranego filtru
%
% ALGORYTMY:
%   • LMS (Least Mean Squares) - prosty algorytm adaptacyjny
%   • NLMS (Normalized LMS) - LMS z normalizacją kroku
%   • RLS (Recursive Least Squares) - algorytm o szybkiej zbieżności
% =========================================================================

% =========================================================================
% OPTYMALIZACJA PARAMETRÓW FILTRÓW
% =========================================================================

% Wywołanie funkcji optymalizacji parametrów dla wszystkich filtrów
try
    logDebug('⚙️ Optymalizacja parametrów filtrów adaptacyjnych...');
    best_params = optimizeAdaptiveFilterParams(original_signal, 0.1);
catch ME
    logError('Błąd optymalizacji filtrów: %s. Używam domyślnych parametrów.', ME.message);
    
    % DOMYŚLNE BEZPIECZNE PARAMETRY
    N = length(noisy_signal);
    safe_order = min(8, floor(N/10));  % Bezpieczny rząd filtru
    
    best_params = struct();
    best_params.M_lms = safe_order;
    best_params.M_nlms = safe_order;
    best_params.M_rls = safe_order;
    best_params.mi = 0.01;
    best_params.alfa = 0.5;
    best_params.beta = 1e-4;
    best_params.lambda = 0.99;
    best_params.delta = 0.1;
    
    logInfo('🔧 Używam domyślnych parametrów: rząd=%d', safe_order);
end

% Wyciągnięcie optymalnych parametrów z struktury wynikowej
M_lms = best_params.M_lms;        % Rząd filtru LMS
M_nlms = best_params.M_nlms;      % Rząd filtru NLMS
M_rls = best_params.M_rls;        % Rząd filtru RLS
mi = best_params.mi;              % Współczynnik uczenia LMS
alfa = best_params.alfa;          % Współczynnik adaptacji NLMS
beta = best_params.beta;          % Stała regularyzacji NLMS
lambda = best_params.lambda;      % Współczynnik zapominania RLS
delta = best_params.delta;        % Parametr inicjalizacji RLS

% =========================================================================
% PRZYGOTOWANIE ZMIENNYCH
% =========================================================================

N = length(noisy_signal);         % Długość sygnału

% =========================================================================
% INICJALIZACJA FILTRÓW ADAPTACYJNYCH
% =========================================================================

% Filtr LMS
w_lms = zeros(M_lms, 1);          % Wektor współczynników LMS
x_buff_lms = zeros(M_lms, 1);     % Bufor danych wejściowych LMS
y_lms = zeros(N, 1);              % Sygnał wyjściowy LMS

% Filtr NLMS
w_nlms = zeros(M_nlms, 1);        % Wektor współczynników NLMS
x_buff_nlms = zeros(M_nlms, 1);   % Bufor danych wejściowych NLMS
y_nlms = zeros(N, 1);             % Sygnał wyjściowy NLMS

% Filtr RLS
w_rls = zeros(M_rls, 1);          % Wektor współczynników RLS
P = (1/delta) * eye(M_rls);       % Macierz kowariancji odwrotna RLS
x_buff_rls = zeros(M_rls, 1);     % Bufor danych wejściowych RLS
y_rls = zeros(N, 1);              % Sygnał wyjściowy RLS

% =========================================================================
% RÓWNOLEGŁA FILTRACJA TRZEMA METODAMI
% =========================================================================

%fprintf('🔄 Filtracja sygnału trzema metodami adaptacyjnymi...\n');

% Określenie punktu startowego (największy rząd filtru)
start_index = max([M_lms, M_nlms, M_rls]);

for n = start_index:N
    % =====================================================================
    % FILTRACJA METODĄ LMS
    % =====================================================================
    if n >= M_lms
        % Aktualizacja bufora danych (okno przesuwne)
        x_buff_lms = [noisy_signal(n); x_buff_lms(1:M_lms-1)];
        
        % Obliczenie wyjścia filtru (iloczyn skalarny)
        y_lms(n) = w_lms' * x_buff_lms;
        
        % Obliczenie błędu predykcji
        e_lms = original_signal(n) - y_lms(n);
        
        % Aktualizacja współczynników algorytmem LMS
        w_lms = w_lms + mi * e_lms * x_buff_lms;
    end
    
    % =====================================================================
    % FILTRACJA METODĄ NLMS
    % =====================================================================
    if n >= M_nlms
        % Aktualizacja bufora danych
        x_buff_nlms = [noisy_signal(n); x_buff_nlms(1:M_nlms-1)];
        
        % Obliczenie wyjścia filtru
        y_nlms(n) = w_nlms' * x_buff_nlms;
        
        % Obliczenie błędu
        e_nlms = original_signal(n) - y_nlms(n);
        
        % Aktualizacja współczynników z normalizacją
        normalization = beta + x_buff_nlms' * x_buff_nlms;
        w_nlms = w_nlms + (alfa / normalization) * e_nlms * x_buff_nlms;
    end
    
    % =====================================================================
    % FILTRACJA METODĄ RLS
    % =====================================================================
    if n >= M_rls
        % Aktualizacja bufora danych
        x_buff_rls = [noisy_signal(n); x_buff_rls(1:M_rls-1)];
        
        % Obliczenie wektora wzmocnienia Kalmana
        denominator = lambda + x_buff_rls' * P * x_buff_rls;
        k = (P * x_buff_rls) / denominator;
        
        % Obliczenie wyjścia filtru
        y_rls(n) = w_rls' * x_buff_rls;
        
        % Obliczenie błędu
        e_rls = original_signal(n) - y_rls(n);
        
        % Aktualizacja współczynników
        w_rls = w_rls + k * e_rls;
        
        % Aktualizacja macierzy kowariancji odwrotnej
        P = (P - k * x_buff_rls' * P) / lambda;
    end
end

% =========================================================================
% PORÓWNANIE WYNIKÓW I WYBÓR NAJLEPSZEGO FILTRU
% =========================================================================

% Obliczenie MSE dla każdego algorytmu
mse_lms = mean((original_signal - y_lms).^2);
mse_nlms = mean((original_signal - y_nlms).^2);
mse_rls = mean((original_signal - y_rls).^2);

% Znalezienie filtru o najniższym MSE
[best_mse, best_idx] = min([mse_lms, mse_nlms, mse_rls]);
filter_names = {'LMS', 'NLMS', 'RLS'};

% Wybór najlepszego sygnału przefiltrowanego
switch best_idx
    case 1
        filtered_signal = y_lms;
        %fprintf('✅ Wybrano filtr LMS (MSE: %.6f)\n', mse_lms);
    case 2
        filtered_signal = y_nlms;
        %fprintf('✅ Wybrano filtr NLMS (MSE: %.6f)\n', mse_nlms);
    case 3
        filtered_signal = y_rls;
        %fprintf('✅ Wybrano filtr RLS (MSE: %.6f)\n', mse_rls);
end

% Zwrócenie MSE najlepszego filtru
mse_improvement = best_mse;

% =========================================================================
% STATYSTYKI WYDAJNOŚCI
% =========================================================================

% Obliczenie MSE sygnału zaszumionego (referencja)
mse_noisy = mean((original_signal - noisy_signal).^2);

% Obliczenie procentowej poprawy
if mse_noisy > 0
    improvement_percent = 100 * (mse_noisy - best_mse) / mse_noisy;
    %fprintf('📈 Poprawa jakości sygnału: %.1f%% (MSE: %.6f → %.6f)\n', ...
    %    improvement_percent, mse_noisy, best_mse);
else
    %fprintf('⚠️ Nie można obliczyć poprawy - MSE sygnału zaszumionego wynosi 0\n');
end

end