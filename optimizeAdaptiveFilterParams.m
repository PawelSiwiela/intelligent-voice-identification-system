function [best_params] = optimizeAdaptiveFilterParams(y, noise_level)
% Optymalizacja parametrów filtrów adaptacyjnych LMS, NLMS i RLS
%
% Argumenty:
%   y - sygnał wejściowy
%   noise_level - poziom szumu (0-1)
%
% Zwraca:
%   best_params - struktura z optymalnymi parametrami dla wszystkich filtrów

% Start pomiaru całkowitego czasu
% total_time_start = tic;

% Podstawowe parametry
N = length(y);           % Długość sygnału

% Zakresy parametrów do optymalizacji
M_range = [4, 8, 16, 20, 32, 50, 100];    % Wspólny zakres rzędów filtrów
mi_range = [0.001, 0.01, 0.05, 0.1];      % Wartości dla LMS
alfa_range = [0.1, 0.5, 0.9, 0.99];       % Wartości dla NLMS
beta_range = [1e-6, 1e-4, 1e-2];          % Wartości dla NLMS
lambda_range = [0.95, 0.99];              % Wartości dla RLS
delta_range = [0.01, 0.1, 1];             % Wartości dla RLS

% Dodanie szumu do sygnału
noisy_signal = y + noise_level * randn(size(y));
mse_noisy = mean((y - noisy_signal).^2);    % Obliczenie MSE zaszumionego sygnału

% Wagi dla optymalizacji
mse_weight = 0.95;       % Waga dla MSE (95%)
order_weight = 0.01;     % Waga dla rzędu filtru (1%)
time_weight = 0.04;      % Waga dla czasu wykonania (4%)

% Inicjalizacja najlepszych wyników
best_score_lms = Inf;
best_score_nlms = Inf;
best_score_rls = Inf;
%best_mse_lms = Inf;
%best_mse_nlms = Inf;
%best_mse_rls = Inf;
best_params = struct();

% Utworzenie paska postępu dla optymalizacji
% total_iterations = length(M_range)*(length(mi_range) + ...
%     length(alfa_range)*length(beta_range) + ...
%     length(lambda_range)*length(delta_range));
% h_opt = waitbar(0, 'Optymalizacja parametrów...', 'Name', 'Postęp optymalizacji');
% current_iteration = 0;

% Po inicjalizacji parametrów dodajemy maksymalny akceptowalny czas
max_acceptable_time = 0.3; % zmniejszenie z 0.2s na 0.1s

% Optymalizacja LMS
%fprintf('\nOptymalizacja LMS:\n');
too_slow_lms = false;

for M_test = M_range
    if too_slow_lms
        %fprintf('Pomijam pozostałe wartości M dla LMS, gdyż już przekroczono limit czasu.\n');
        break;
    end
    
    for mi_test = mi_range
        % Inicjalizacja filtra LMS
        w = zeros(M_test, 1);
        x_buff = zeros(M_test, 1);
        y_filtered = zeros(N, 1);
        
        % Start pomiaru czasu
        tic;
        
        % Filtracja LMS (tylko raz)
        for n = M_test:N
            x_buff = [noisy_signal(n); x_buff(1:M_test-1)];
            y_filtered(n) = w' * x_buff;
            e = y(n) - y_filtered(n);
            w = w + mi_test * e * x_buff;
        end
        
        % Koniec pomiaru czasu
        execution_time = toc;
        
        % Sprawdzenie czasu wykonania
        if execution_time > max_acceptable_time
            %fprintf('Przerwano optymalizację LMS dla M = %d (czas wykonania %.3fs > %.3fs)\n', ...
            %    M_test, execution_time, max_acceptable_time);
            too_slow_lms = true;
            break;
        end
        
        % Obliczenie score z uwzględnieniem czasu
        mse_test = mean((y - y_filtered).^2);
        order_penalty = M_test / max(M_range);
        time_penalty = min(execution_time, 1.0); % Ograniczenie kary czasowej do 1.0
        score = mse_weight * (mse_test/mse_noisy) + ...
            order_weight * order_penalty + ...
            time_weight * time_penalty;
        
        %fprintf('M = %d, mi = %.4f: MSE = %.6f, Time = %.3fs (Score = %.6f)\n', ...
        %     M_test, mi_test, mse_test, execution_time, score);
        
        if score < best_score_lms
            best_score_lms = score;
            %best_mse_lms = mse_test;
            best_params.M_lms = M_test;
            best_params.mi = mi_test;
            best_params.time_lms = execution_time;
        end
    end
end

% Optymalizacja NLMS
%fprintf('\nOptymalizacja NLMS:\n');
too_slow_nlms = false;

for M_test = M_range
    if too_slow_nlms
        %fprintf('Pomijam pozostałe wartości M dla NLMS, gdyż już przekroczono limit czasu.\n');
        break;
    end
    
    for alfa_test = alfa_range
        for beta_test = beta_range
            % Inicjalizacja filtra NLMS
            w = zeros(M_test, 1);
            x_buff = zeros(M_test, 1);
            y_filtered = zeros(N, 1);
            
            % Start pomiaru czasu
            tic;
            
            % Filtracja NLMS
            for n = M_test:N
                x_buff = [noisy_signal(n); x_buff(1:M_test-1)];
                y_filtered(n) = w' * x_buff;
                e = y(n) - y_filtered(n);
                w = w + alfa_test/(beta_test + x_buff'*x_buff) * e * x_buff;
            end
            
            % Koniec pomiaru czasu
            execution_time = toc;
            
            % Sprawdzenie czasu wykonania
            if execution_time > max_acceptable_time
                %fprintf('Przerwano optymalizację NLMS dla M = %d (czas wykonania %.3fs > %.3fs)\n', ...
                %    M_test, execution_time, max_acceptable_time);
                too_slow_nlms = true;
                break;
            end
            
            % Obliczenie MSE i score z wagami
            mse_test = mean((y - y_filtered).^2);
            order_penalty = M_test / max(M_range);
            time_penalty = min(execution_time, 1.0);
            score = mse_weight * (mse_test/mse_noisy) + ...
                order_weight * order_penalty + ...
                time_weight * time_penalty;
            
            %fprintf('M = %d, alfa = %.4f, beta = %.6f: MSE = %.6f, Time = %.3fs (Score = %.6f)\n', ...
            %    M_test, alfa_test, beta_test, mse_test, execution_time, score);
            
            if score < best_score_nlms
                best_score_nlms = score;
                %best_mse_nlms = mse_test;
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

% Optymalizacja RLS
%fprintf('\nOptymalizacja RLS:\n');
too_slow_rls = false;

for M_test = M_range
    if too_slow_rls
        %fprintf('Pomijam pozostałe wartości M dla RLS, gdyż już przekroczono limit czasu.\n');
        break;
    end
    
    for lambda_test = lambda_range
        if too_slow_rls
            break;
        end
        
        for delta_test = delta_range
            % Inicjalizacja filtra RLS
            w = zeros(M_test, 1);
            P = (1/delta_test) * eye(M_test);
            x_buff = zeros(M_test, 1);
            y_filtered = zeros(N, 1);
            
            % Start pomiaru czasu
            tic;
            
            % Filtracja RLS
            for n = M_test:N
                x_buff = [noisy_signal(n); x_buff(1:M_test-1)];
                k = (P * x_buff)/(lambda_test + x_buff' * P * x_buff);
                y_filtered(n) = w' * x_buff;
                e = y(n) - y_filtered(n);
                w = w + k * e;
                P = (P - k * x_buff' * P)/lambda_test;
            end
            
            % Koniec pomiaru czasu
            execution_time = toc;
            
            % Jeśli czas wykonania jest zbyt długi, oznacz jako zbyt wolne i przerwij
            if execution_time > max_acceptable_time
                %fprintf('Przerwano optymalizację dla M = %d (czas wykonania %.3fs > %.3fs)\n', ...
                %    M_test, execution_time, max_acceptable_time);
                too_slow_rls = true;  % Ustawienie flagi
                break;  % Przerwanie najbardziej wewnętrznej pętli
            end
            
            % Obliczenie MSE i score z wagami
            mse_test = mean((y - y_filtered).^2);
            order_penalty = M_test / max(M_range);
            time_penalty = min(execution_time, 1.0);
            score = mse_weight * (mse_test/mse_noisy) + ...
                order_weight * order_penalty + ...
                time_weight * time_penalty;
            
            %fprintf('M = %d, lambda = %.4f, delta = %.4f: MSE = %.6f, Time = %.3fs (Score = %.6f)\n', ...
            %    M_test, lambda_test, delta_test, mse_test, execution_time, score);
            
            if score < best_score_rls
                best_score_rls = score;
                %best_mse_rls = mse_test;
                best_params.M_rls = M_test;
                best_params.lambda = lambda_test;
                best_params.delta = delta_test;
                best_params.time_rls = execution_time;
            end
        end
    end
end

%close(h_opt);

% Wyświetlenie najlepszych parametrów i ich efektywności
%fprintf('\nNajlepsze parametry i ich skuteczność:\n');
%fprintf('LMS:\n');
%fprintf('  - Rząd filtru (M): %d\n', best_params.M_lms);
%fprintf('  - Współczynnik uczenia (mi): %.4f\n', best_params.mi);
%fprintf('  - MSE: %.6f (redukcja o %.1f%%)\n', best_mse_lms, 100*(mse_noisy-best_mse_lms)/mse_noisy);
%fprintf('  - Czas wykonania: %.3fs\n', best_params.time_lms);

%fprintf('\nNLMS:\n');
%fprintf('  - Rząd filtru (M): %d\n', best_params.M_nlms);
%fprintf('  - Współczynnik alfa: %.4f\n', best_params.alfa);
%fprintf('  - Współczynnik beta: %.6f\n', best_params.beta);
%fprintf('  - MSE: %.6f (redukcja o %.1f%%)\n', best_mse_nlms, 100*(mse_noisy-best_mse_nlms)/mse_noisy);
%fprintf('  - Czas wykonania: %.3fs\n', best_params.time_nlms);

%fprintf('\nRLS:\n');
%fprintf('  - Rząd filtru (M): %d\n', best_params.M_rls);
%fprintf('  - Współczynnik lambda: %.4f\n', best_params.lambda);
%fprintf('  - Współczynnik delta: %.4f\n', best_params.delta);
%fprintf('  - MSE: %.6f (redukcja o %.1f%%)\n', best_mse_rls, 100*(mse_noisy-best_mse_rls)/mse_noisy);
%fprintf('  - Czas wykonania: %.3fs\n', best_params.time_rls);

% Koniec pomiaru całkowitego czasu
% total_execution_time = toc(total_time_start);

%fprintf('\nCałkowity czas wykonania optymalizacji parametrów: %.2f sekund (%.2f minut)\n', ...
%    total_execution_time, total_execution_time/60);

% Zapisanie najlepszych parametrów do pliku
%save('optimal_parameters.mat', 'best_params');

% Na koniec dodajemy MSE zaszumionego sygnału do struktury
best_params.mse_noisy = mse_noisy;
best_params.noise_level = noise_level;
end