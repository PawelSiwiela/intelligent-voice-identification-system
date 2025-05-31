function visualizeNetworkStructure(net, title_text, save_path)
% VISUALIZENETWORKSTRUCTURE Wizualizuje strukturę sieci neuronowej
%
% Składnia:
%   visualizeNetworkStructure(net, title_text, save_path)
%
% Argumenty:
%   net - sieć neuronowa
%   title_text - opcjonalny tytuł wykresu
%   save_path - opcjonalna ścieżka do zapisania wykresu

% Domyślny tytuł
if nargin < 2
    title_text = 'Struktura sieci neuronowej';
end

% Domyślna ścieżka zapisu (brak - nie zapisuj)
if nargin < 3
    save_path = '';
end

try
    figure('Name', title_text, 'Position', [200, 200, 800, 600]);
    
    % Sprawdźmy czy jest dostępna funkcja plotnet
    if exist('plotnet', 'file') == 2
        % Metoda z Deep Learning Toolbox
        plotnet(net);
        title(title_text);
    else
        % Alternatywna metoda wizualizacji
        input_size = net.inputs{1}.size;
        output_size = net.outputs{end}.size;
        num_layers = length(net.layers);
        
        % Pobierz rozmiary warstw ukrytych
        hidden_sizes = zeros(1, num_layers-1);
        for i = 1:num_layers-1
            hidden_sizes(i) = net.layers{i}.size;
        end
        
        % Przygotowanie do rysowania
        layer_sizes = [input_size, hidden_sizes, output_size];
        max_neurons = max(layer_sizes);
        layer_positions = 1:length(layer_sizes);
        
        % Rysowanie warstw
        hold on;
        
        % Rysowanie połączeń między warstwami
        for i = 1:length(layer_sizes)-1
            for j = 1:layer_sizes(i)
                y1 = j - (layer_sizes(i)+1)/2;
                for k = 1:layer_sizes(i+1)
                    y2 = k - (layer_sizes(i+1)+1)/2;
                    plot([i, i+1], [y1, y2], 'k-', 'LineWidth', 0.2, 'Color', [0.7 0.7 0.7]);
                end
            end
        end
        
        % Rysowanie neuronów jako okręgów
        for i = 1:length(layer_sizes)
            for j = 1:layer_sizes(i)
                y = j - (layer_sizes(i)+1)/2;
                if i == 1
                    col = [0.6, 0.8, 1];  % Wejście: jasnoniebieskie
                elseif i == length(layer_sizes)
                    col = [1, 0.6, 0.6];  % Wyjście: jasnoróżowe
                else
                    col = [0.8, 0.8, 1];  % Ukryte: jasnofioletowe
                end
                rectangle('Position', [i-0.3, y-0.3, 0.6, 0.6], ...
                    'Curvature', [1,1], ...
                    'FaceColor', col, ...
                    'EdgeColor', 'k');
            end
        end
        
        % Etykiety warstw
        layer_names = cell(1, length(layer_sizes));
        layer_names{1} = 'Wejście';
        for i = 2:length(layer_sizes)-1
            activ_fcn = net.layers{i-1}.transferFcn;
            layer_names{i} = sprintf('Ukryta (%s)', activ_fcn);
        end
        layer_names{end} = 'Wyjście';
        
        % Dodanie etykiet warstw
        for i = 1:length(layer_sizes)
            text(i, max_neurons/2 + 1, layer_names{i}, ...
                'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold');
            text(i, max_neurons/2 + 2, sprintf('(%d)', layer_sizes(i)), ...
                'HorizontalAlignment', 'center');
        end
        
        % Dodanie informacji o algorytmie uczenia
        info_text = sprintf('Algorytm uczenia: %s', net.trainFcn);
        text(mean(layer_positions), -max_neurons/2 - 1, info_text, ...
            'HorizontalAlignment', 'center', ...
            'FontWeight', 'bold');
        
        hold off;
        
        % Dostosowanie wykresu
        axis([0.5, length(layer_sizes)+0.5, -max_neurons/2-3, max_neurons/2+3]);
        axis equal;
        axis off;
        title(title_text);
    end
    
    % Zapisanie wizualizacji jeśli podano ścieżkę
    if ~isempty(save_path)
        % Sprawdzenie czy folder istnieje, jeśli nie - utworzenie
        viz_dir = fileparts(save_path);
        if ~exist(viz_dir, 'dir')
            mkdir(viz_dir);
            logInfo('📁 Utworzono katalog dla wizualizacji: %s', viz_dir);
        end
        
        % Zapisanie figury
        saveas(h, save_path);
        logInfo('💾 Zapisano wizualizację struktury sieci: %s', save_path);
    end
    
catch e
    logError('❌ Błąd podczas generowania wizualizacji struktury sieci: %s', e.message);
end

end