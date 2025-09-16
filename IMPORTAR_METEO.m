function [T_exterior, HR] = IMPORTAR_METEO(nomFitxer)

    if ~isfile(nomFitxer)
        error(['No es troba el fitxer: ', nomFitxer]);
    end

    % Detectar opcions de lectura
    opts = detectImportOptions(nomFitxer, 'NumHeaderLines', 18);        %modificar inici fitxer
    opts.SelectedVariableNames = [2, 3];  % Columna 2 = T, Columna 3 = HR

    % Llegir taula
    T = readtable(nomFitxer, opts);

    % Extreure vectors
    T_exterior = T{:,1};
    HR = T{:,2};

 % Ajustar longitud
    n = length(T_exterior);

    if n > 8760
        % Sobra → tallem
        T_exterior = T_exterior(1:8760);
        HR = HR(1:8760);

    elseif n < 8760
        % Falta → anem copiant blocs de 24 hores fins arribar
        warning(['El fitxer només té ', num2str(n), ...
                 ' hores. Es completaran fins 8760 repetint el darrer dia.']);
        while length(T_exterior) < 8760
            falta = 8760 - length(T_exterior);
            if falta >= 24
                T_exterior = [T_exterior; T_exterior(end-23:end)];
                HR = [HR; HR(end-23:end)];
            else
                % Si falten menys de 24, copiem només les que calguin
                T_exterior = [T_exterior; T_exterior(end-falta+1:end)];
                HR = [HR; HR(end-falta+1:end)];
            end
        end
    end
end
