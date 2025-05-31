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
    % Utworzenie nowej figury
    h = figure('Name', title_text, 'Position', [200, 200, 900, 700]);
    
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
        layer_positions = 1:length(layer_sizes);
        
        % Pobierz funkcje aktywacji
        if length(net.layers) > 0
            activation_functions = cell(1, length(net.layers));
            for i = 1:length(net.layers)
                activation_functions{i} = net.layers{i}.transferFcn;
            end
        else
            activation_functions = {'unknown'};
        end
        
        % Rozpocznij rysowanie
        clf;
        hold on;
        
        % Rysuj warstwy jako prostokąty z etykietami
        spacing = 2;  % Zwiększ odstęp między warstwami
        max_size = max(layer_sizes) * 1.2;
        
        % Kolory warstw
        input_color = [0.7, 0.9, 1.0];     % Jasny niebieski
        hidden_color = [0.9, 0.8, 1.0];    % Jasny fioletowy
        output_color = [1.0, 0.8, 0.8];    % Jasny czerwony
        
        % Rysuj warstwy
        for i = 1:length(layer_sizes)
            x_pos = i * spacing;
            
            % Wybierz kolor dla warstwy
            if i == 1
                box_color = input_color;
                layer_name = 'Wejściowa';
            elseif i == length(layer_sizes)
                box_color = output_color;
                layer_name = 'Wyjściowa';
            else
                box_color = hidden_color;
                layer_name = sprintf('Ukryta %d', i-1);
            end
            
            % Rysuj prostokąt dla warstwy
            width = 1.5;
            height = layer_sizes(i) * 0.8;
            rectangle('Position', [x_pos-width/2, -height/2, width, height], ...
                'FaceColor', box_color, 'EdgeColor', 'k', 'LineWidth', 1.5, ...
                'Curvature', [0.2, 0.2]);
            
            % Dodaj etykietę warstwy
            text(x_pos, height/2 + 0.5, layer_name, 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            text(x_pos, height/2 + 1.5, sprintf('(%d neurony)', layer_sizes(i)), 'HorizontalAlignment', 'center');
            
            % Dodaj info o funkcji aktywacji dla warstw ukrytych i wyjściowej
            if i > 1
                activ_text = sprintf('Aktywacja: %s', activation_functions{i-1});
                text(x_pos, -height/2 - 1.0, activ_text, 'HorizontalAlignment', 'center');
            end
        end
        
        % Dodaj strzałki między warstwami
        arrow_color = [0.5, 0.5, 0.5];
        for i = 1:length(layer_sizes)-1
            x1 = i * spacing + 0.75;
            x2 = (i+1) * spacing - 0.75;
            
            % Narysuj strzałkę
            arrow([x1, 0], [x2, 0], 'Color', arrow_color, 'LineWidth', 1.5);
        end
        
        % Dodaj informację o algorytmie uczenia
        learn_text = sprintf('Algorytm uczenia: %s', net.trainFcn);
        text(mean(layer_positions) * spacing, -max_size/2 - 2.5, learn_text, ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 11);
        
        % Dodatkowe informacje o sieci
        net_type = class(net);
        if length(net_type) > 15
            net_type = net_type(1:15);  % Skróć jeśli zbyt długie
        end
        
        info_text = sprintf('Typ sieci: %s', net_type);
        text(mean(layer_positions) * spacing, -max_size/2 - 3.5, info_text, ...
            'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 11);
        
        % Ustaw granice wykresu
        total_width = (length(layer_sizes) + 0.5) * spacing;
        axis([-spacing/2, total_width, -max_size/2 - 5, max_size/2 + 3]);
        
        % Wyłącz osie
        axis off;
        
        % Tytuł
        title(title_text, 'FontSize', 14);
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

% Pomocnicza funkcja do rysowania strzałek
    function arrow(start_point, end_point, varargin)
        x = [start_point(1), end_point(1)];
        y = [start_point(2), end_point(2)];
        
        % Narysuj linię
        plot(x, y, varargin{:});
        
        % Oblicz kierunek strzałki
        dx = end_point(1) - start_point(1);
        dy = end_point(2) - start_point(2);
        len = sqrt(dx^2 + dy^2);
        unitx = dx/len;
        unity = dy/len;
        
        % Parametry grotu strzałki
        head_length = 0.3;
        head_width = 0.15;
        
        % Oblicz punkty grotu strzałki
        points = [
            end_point(1), end_point(2);
            end_point(1) - head_length*unitx - head_width*unity, end_point(2) - head_length*unity + head_width*unitx;
            end_point(1) - head_length*unitx + head_width*unity, end_point(2) - head_length*unity - head_width*unitx
            ];
        
        % Narysuj grot strzałki
        fill(points(:,1), points(:,2), varargin{2:end});
    end

end