function [filtered_signal, mse_improvement] = applyAdaptiveFilters(noisy_signal, original_signal)
% Filtracja adaptacyjna sygnału z wykorzystaniem algorytmów LMS, NLMS i RLS
%
% Argumenty:
%   noisy_signal - zaszumiony sygnał wejściowy
%   original_signal - oryginalny sygnał (do obliczenia MSE)
%
% Zwraca:
%   filtered_signal - przefiltrowany sygnał (najlepszy z trzech algorytmów)
%   mse_improvement - wartość MSE dla najlepszego algorytmu

% Dodanie komentarzy opisujących etapy
% Optymalizacja parametrów
if nargin < 3
    best_params = optimizeAdaptiveFilterParams(original_signal, 0.1);
    M_lms = best_params.M_lms;
    M_nlms = best_params.M_nlms;
    M_rls = best_params.M_rls;
    mi = best_params.mi;
    alfa = best_params.alfa;
    beta = best_params.beta;
    lambda = best_params.lambda;
    delta = best_params.delta;
end

N = length(noisy_signal);

% Inicjalizacja filtrów adaptacyjnych
% ...initialization code...
w_lms = zeros(M_lms, 1);
w_nlms = zeros(M_nlms, 1);
w_rls = zeros(M_rls, 1);
P = (1/delta) * eye(M_rls);
x_buff_lms = zeros(M_lms, 1);
x_buff_nlms = zeros(M_nlms, 1);
x_buff_rls = zeros(M_rls, 1);
y_lms = zeros(N, 1);
y_nlms = zeros(N, 1);
y_rls = zeros(N, 1);

% Filtracja sygnału trzema metodami
for n = max([M_lms, M_nlms, M_rls]):N
    % Metoda LMS
    x_buff_lms = [noisy_signal(n); x_buff_lms(1:M_lms-1)];
    y_lms(n) = w_lms' * x_buff_lms;
    e_lms = original_signal(n) - y_lms(n);
    w_lms = w_lms + mi * e_lms * x_buff_lms;
    
    % Metoda NLMS
    x_buff_nlms = [noisy_signal(n); x_buff_nlms(1:M_nlms-1)];
    y_nlms(n) = w_nlms' * x_buff_nlms;
    e_nlms = original_signal(n) - y_nlms(n);
    w_nlms = w_nlms + alfa/(beta + x_buff_nlms'*x_buff_nlms) * e_nlms * x_buff_nlms;
    
    % Metoda RLS
    x_buff_rls = [noisy_signal(n); x_buff_rls(1:M_rls-1)];
    k = (P * x_buff_rls)/(lambda + x_buff_rls' * P * x_buff_rls);
    y_rls(n) = w_rls' * x_buff_rls;
    e_rls = original_signal(n) - y_rls(n);
    w_rls = w_rls + k * e_rls;
    P = (P - k * x_buff_rls' * P)/lambda;
end

% Obliczenie MSE dla każdego algorytmu
%mse_noisy = mean((original_signal - noisy_signal).^2);
mse_lms = mean((original_signal - y_lms).^2);
mse_nlms = mean((original_signal - y_nlms).^2);
mse_rls = mean((original_signal - y_rls).^2);

% Wybór najlepszego wyniku na podstawie MSE
[best_mse, best_idx] = min([mse_lms, mse_nlms, mse_rls]);

% Wybór najlepszego sygnału
switch best_idx
    case 1
        filtered_signal = y_lms;
        %fprintf('Wybrano filtr LMS (MSE: %.6f, redukcja o %.1f%%)\n', ...
        %    mse_lms, 100*(mse_noisy-mse_lms)/mse_noisy);
    case 2
        filtered_signal = y_nlms;
        %fprintf('Wybrano filtr NLMS (MSE: %.6f, redukcja o %.1f%%)\n', ...
        %    mse_nlms, 100*(mse_noisy-mse_nlms)/mse_noisy);
    case 3
        filtered_signal = y_rls;
        %fprintf('Wybrano filtr RLS (MSE: %.6f, redukcja o %.1f%%)\n', ...
        %    mse_rls, 100*(mse_noisy-mse_rls)/mse_noisy);
end

mse_improvement = best_mse;
end