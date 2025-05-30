function features = envelopeFeatures(signal)
% ENVELOPEFEATURES Ekstrakcja cech obwiedni sygnału audio
%
% Składnia:
%   features = envelopeFeatures(signal)
%
% Argumenty:
%   signal - sygnał audio
%
% Zwraca:
%   features - struktura zawierająca cechy obwiedni
%     - upper_mean: Średnia górnej obwiedni
%     - upper_std: Zmienność górnej obwiedni
%     - lower_mean: Średnia dolnej obwiedni
%     - lower_std: Zmienność dolnej obwiedni
%     - diff_mean: Średnia różnica między obwiedniami
%     - env_ratio: Stosunek obwiedni
%     - env_range: Zakres obwiedni

% Inicjalizacja struktury wynikowej
features = struct();

% Obliczenie obwiedni sygnału
% Używamy transformaty Hilberta do znalezienia obwiedni analitycznej
analytic_signal = hilbert(signal);
envelope_upper = abs(analytic_signal);  % Obwiednia górna

% Dla dolnej obwiedni, odwracamy sygnał i powtarzamy proces
envelope_lower = -abs(hilbert(-signal));  % Obwiednia dolna

% 1. Średnia górnej obwiedni
features.upper_mean = mean(envelope_upper);

% 2. Zmienność górnej obwiedni (odchylenie standardowe)
features.upper_std = std(envelope_upper);

% 3. Średnia dolnej obwiedni
features.lower_mean = mean(envelope_lower);

% 4. Zmienność dolnej obwiedni (odchylenie standardowe)
features.lower_std = std(envelope_lower);

% 5. Średnia różnica między obwiedniami
env_diff = envelope_upper - envelope_lower;
features.diff_mean = mean(env_diff);

% 6. Stosunek obwiedni (iloraz między średnią górnej a dolnej obwiedni)
if features.lower_mean ~= 0
    features.env_ratio = abs(features.upper_mean / features.lower_mean);
else
    features.env_ratio = 0;
end

% 7. Zakres obwiedni (różnica między wartościami maksymalnymi i minimalnymi)
features.env_range = max(envelope_upper) - min(envelope_lower);

end