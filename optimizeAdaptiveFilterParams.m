function [best_params] = optimizeAdaptiveFilterParams(y, noise_level)
% =========================================================================
% OPTYMALIZACJA PARAMETRÓW FILTRÓW ADAPTACYJNYCH
% =========================================================================
% Funkcja optymalizuje parametry dla trzech typów filtrów adaptacyjnych:
% LMS, NLMS i RLS w celu minimalizacji błędu średniokwadratowego (MSE)
% przy jednoczesnym zachowaniu akceptowalnego czasu wykonania
%
% ARGUMENTY:
%   y - oryginalny sygnał wejściowy (wektor)
%   noise_level - poziom szumu dodawanego do sygnału (0.0-1.0)
%
% ZWRACA:
%   best_params - struktura zawierająca optymalne parametry dla wszystkich filtrów:
%     .M_lms, .mi - parametry filtru LMS
%     .M_nlms, .alfa, .beta - parametry filtru NLMS
%     .M_rls, .lambda, .delta - parametry filtru RLS
%     .time_lms, .time_nlms, .time_rls - czasy wykonania
%     .mse_noisy, .noise_level - informacje o sygnale
% =========================================================================

% =========================================================================
% PARAMETRY PODSTAWOWE
% =========================================================================

N = length(y);           % Długość sygnału wejściowego

% Zakresy parametrów do przeszukiwania dla optymalizacji
M_range = [4, 8, 16, 20, 32, 50, 100];    % Rząd filtru (liczba współczynników)
mi_range = [0.001, 0.01, 0.05, 0.1];      % Współczynnik uczenia dla LMS
alfa_range = [0.1, 0.5, 0.9, 0.99];       % Współczynnik adaptacji dla NLMS
beta_range = [1e-6, 1e-4, 1e-2];          % Stała regularyzacji dla NLMS
lambda_range = [0.95, 0.99];              % Współczynnik zapominania dla RLS
delta_range = [0.01, 0.1, 1];             % Stała inicjalizacji macierzy P dla RLS

% =========================================================================
% PRZYGOTOWANIE SYGNAŁU TESTOWEGO
% =========================================================================

% Dodanie szumu gaussowskiego do oryginalnego sygnału
noisy_signal = y + noise_level * randn(size(y));

% Obliczenie MSE sygnału zaszumionego (referencja do porównań)
mse_noisy = mean((y - noisy_signal).^2);

% =========================================================================
% KONFIGURACJA SYSTEMU OCENY
% =========================================================================

% Wagi dla funkcji oceny (muszą sumować się do 1.0)
mse_weight = 0.95;       % Waga dla dokładności filtracji (95%)
order_weight = 0.01;     % Waga dla złożoności filtru (1%)
time_weight = 0.04;      % Waga dla szybkości wykonania (4%)

% Maksymalny akceptowalny czas wykonania filtracji (w sekundach)
max_acceptable_time = 0.3;

% =========================================================================
% INICJALIZACJA ZMIENNYCH WYNIKOWYCH
% =========================================================================

% Najlepsze wyniki dla każdego typu filtru
best_score_lms = Inf;    % Najlepszy wynik oceny dla LMS
best_score_nlms = Inf;   % Najlepszy wynik oceny dla NLMS
best_score_rls = Inf;    % Najlepszy wynik oceny dla RLS

% Struktura przechowująca optymalne parametry
best_params = struct();

% =========================================================================
% OPTYMALIZACJA FILTRU LMS (Least Mean Squares)
% =========================================================================

fprintf('🔧 Optymalizacja parametrów filtru LMS...\n');
too_slow_lms = false;    % Flaga sygnalizująca przekroczenie limitu czasu

for M_test = M_range
    % Sprawdzenie czy poprzednie testy były zbyt wolne
    if too_slow_lms
        break;
    end
    
    for mi_test = mi_range
        % Inicjalizacja struktury filtru LMS
        w = zeros(M_test, 1);           % Wektor współczynników filtru
        x_buff = zeros(M_test, 1);      % Bufor danych wejściowych
        y_filtered = zeros(N, 1);       % Sygnał wyjściowy
        
        % Pomiar czasu wykonania filtracji
        tic;
        
        % Główna pętla filtracji LMS
        for n = M_test:N
            % Aktualizacja bufora danych wejściowych (okno przesuwne)
            x_buff = [noisy_signal(n); x_buff(1:M_test-1)];
            
            % Obliczenie wyjścia filtru (konwolucja z współczynnikami)
            y_filtered(n) = w' * x_buff;
            
            % Obliczenie błędu predykcji
            e = y(n) - y_filtered(n);
            
            % Aktualizacja współczynników filtru (algorytm LMS)
            w = w + mi_test * e * x_buff;
        end
        
        execution_time = toc;
        
        % Sprawdzenie kryterium czasowego
        if execution_time > max_acceptable_time
            too_slow_lms = true;
            break;
        end
        
        % Obliczenie funkcji oceny (im mniejsza, tym lepsza)
        mse_test = mean((y - y_filtered).^2);
        order_penalty = M_test / max(M_range);           % Kara za złożoność
        time_penalty = min(execution_time, 1.0);         % Kara za czas wykonania
        
        score = mse_weight * (mse_test/mse_noisy) + ...
            order_weight * order_penalty + ...
            time_weight * time_penalty;
        
        % Sprawdzenie czy to najlepszy wynik jak dotąd
        if score < best_score_lms
            best_score_lms = score;
            best_params.M_lms = M_test;
            best_params.mi = mi_test;
            best_params.time_lms = execution_time;
        end
    end
end

% =========================================================================
% OPTYMALIZACJA FILTRU NLMS (Normalized Least Mean Squares)
% =========================================================================

fprintf('🔧 Optymalizacja parametrów filtru NLMS...\n');
too_slow_nlms = false;

for M_test = M_range
    if too_slow_nlms
        break;
    end
    
    for alfa_test = alfa_range
        for beta_test = beta_range
            % Inicjalizacja struktury filtru NLMS
            w = zeros(M_test, 1);
            x_buff = zeros(M_test, 1);
            y_filtered = zeros(N, 1);
            
            tic;
            
            % Główna pętla filtracji NLMS
            for n = M_test:N
                % Aktualizacja bufora danych
                x_buff = [noisy_signal(n); x_buff(1:M_test-1)];
                
                % Obliczenie wyjścia filtru
                y_filtered(n) = w' * x_buff;
                
                % Obliczenie błędu
                e = y(n) - y_filtered(n);
                
                % Aktualizacja współczynników z normalizacją (algorytm NLMS)
                normalization_factor = beta_test + x_buff' * x_buff;
                w = w + (alfa_test / normalization_factor) * e * x_buff;
            end
            
            execution_time = toc;
            
            % Sprawdzenie kryterium czasowego
            if execution_time > max_acceptable_time
                too_slow_nlms = true;
                break;
            end
            
            % Obliczenie funkcji oceny
            mse_test = mean((y - y_filtered).^2);
            order_penalty = M_test / max(M_range);
            time_penalty = min(execution_time, 1.0);
            
            score = mse_weight * (mse_test/mse_noisy) + ...
                order_weight * order_penalty + ...
                time_weight * time_penalty;
            
            % Aktualizacja najlepszego wyniku
            if score < best_score_nlms
                best_score_nlms = score;
                best_params.M_nlms = M_test;
                best_params.alfa = alfa_test;
                best_params.beta = beta_test;
                best_params.time_nlms = execution_time;
            end
        end
        
        if too_slow_nlms
            break;
        end
    end
end

% =========================================================================
% OPTYMALIZACJA FILTRU RLS (Recursive Least Squares)
% =========================================================================

fprintf('🔧 Optymalizacja parametrów filtru RLS...\n');
too_slow_rls = false;

for M_test = M_range
    if too_slow_rls
        break;
    end
    
    for lambda_test = lambda_range
        if too_slow_rls
            break;
        end
        
        for delta_test = delta_range
            % Inicjalizacja struktury filtru RLS
            w = zeros(M_test, 1);                    % Wektor współczynników
            P = (1/delta_test) * eye(M_test);        % Macierz kowariancji odwrotna
            x_buff = zeros(M_test, 1);               % Bufor danych
            y_filtered = zeros(N, 1);                % Sygnał wyjściowy
            
            tic;
            
            % Główna pętla filtracji RLS
            for n = M_test:N
                % Aktualizacja bufora danych
                x_buff = [noisy_signal(n); x_buff(1:M_test-1)];
                
                % Obliczenie wektora wzmocnienia Kalmana
                denominator = lambda_test + x_buff' * P * x_buff;
                k = (P * x_buff) / denominator;
                
                % Obliczenie wyjścia filtru
                y_filtered(n) = w' * x_buff;
                
                % Obliczenie błędu
                e = y(n) - y_filtered(n);
                
                % Aktualizacja współczynników (algorytm RLS)
                w = w + k * e;
                
                % Aktualizacja macierzy kowariancji odwrotnej
                P = (P - k * x_buff' * P) / lambda_test;
            end
            
            execution_time = toc;
            
            % Sprawdzenie kryterium czasowego
            if execution_time > max_acceptable_time
                too_slow_rls = true;
                break;
            end
            
            % Obliczenie funkcji oceny
            mse_test = mean((y - y_filtered).^2);
            order_penalty = M_test / max(M_range);
            time_penalty = min(execution_time, 1.0);
            
            score = mse_weight * (mse_test/mse_noisy) + ...
                order_weight * order_penalty + ...
                time_weight * time_penalty;
            
            % Aktualizacja najlepszego wyniku
            if score < best_score_rls
                best_score_rls = score;
                best_params.M_rls = M_test;
                best_params.lambda = lambda_test;
                best_params.delta = delta_test;
                best_params.time_rls = execution_time;
            end
        end
    end
end

% =========================================================================
% FINALIZACJA WYNIKÓW
% =========================================================================

% Dodanie metadanych do struktury wynikowej
best_params.mse_noisy = mse_noisy;        % MSE sygnału zaszumionego
best_params.noise_level = noise_level;    % Poziom zastosowanego szumu

fprintf('✅ Optymalizacja parametrów filtrów adaptacyjnych zakończona.\n');

end