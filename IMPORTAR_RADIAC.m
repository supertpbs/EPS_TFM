function [vector] = llegirRadiacioCSV(nomFitxer)
% Llegeix el vector horari de 8760 valors de la 2a columna del CSV a partir de la fila 8

    % Comprovem si l’arxiu existeix
    if ~isfile(nomFitxer)
        error(['No es troba el fitxer: ', nomFitxer]);
    end

    % Llegim el contingut complet del CSV
    opts = detectImportOptions(nomFitxer, 'NumHeaderLines', 7);  % salta 7 línies → fila 8 és la primera que llegim
    opts.SelectedVariableNames = 2;                              % 2a columna
    T = readtable(nomFitxer, opts);

    % Convertim la taula a un vector
    vector = T{:,1};

    % Comprovació de longitud
    if length(vector) ~= 8760
     %   error(['El vector llegit de ', nomFitxer, ' té ', num2str(length(vector)), ...
    vector = vector(1:8760);
    end
end