function [dataES, sumaPrecioMedio] = IMPORTAR_OMIE(carpeta)
% IMPORTARPRECIOSOMIE Lee precios OMIE y devuelve 3x8760 (Max, Min, Medio ES)
% además devuelve la suma de la fila 3 (precio medio) tras corregir NaN

    files = dir(fullfile(carpeta, 'precios_pibcic_2022*.1'));
    % Orden cronológico
    [~, idx] = sort({files.name});
    files = files(idx);

    % Prealocación con un pelín más de espacio por seguridad
    dataES = zeros(3, 8800);
    hourIndex = 1;

    for k = 1:length(files)
        filePath = fullfile(carpeta, files(k).name);

        fid = fopen(filePath, 'r');
        rawLines = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
        fclose(fid);
        rawLines = rawLines{1};

        startLine = find(contains(rawLines, 'Año;Mes;Día;Hora;'), 1, 'first');
        dataLines = rawLines(startLine+1:end);
        dataLines = dataLines(~cellfun('isempty', dataLines));

        for i = 1:length(dataLines)
            % Reemplazar coma por punto antes de convertir a número
            lineDots = strrep(dataLines{i}, ',', '.');
            vals = str2double(split(lineDots, ';'));
            hora = vals(4);

            % Saltar hora 24 salvo en último archivo y última línea
            if hora == 24 && k < length(files)
                continue
            end

            dataES(1, hourIndex) = vals(5);   % MáximoES
            dataES(2, hourIndex) = vals(8);   % MínimoES
            dataES(3, hourIndex) = vals(11);  % MedioES

            hourIndex = hourIndex + 1;
        end
    end

    % Recortar a tamaño exacto
    dataES = dataES(:, 1:hourIndex-1);

    % Si sobra por algún duplicado raro, recortar a 8760
    if size(dataES, 2) > 8760
        dataES = dataES(:, 1:8760);
    end

    % Corregir NaN en todas las filas con valor anterior
    for fila = 1:3
        nanIdx = isnan(dataES(fila,:));
        for i = 1:length(dataES(fila,:))
            if nanIdx(i)
                if i == 1
                    dataES(fila,i) = 0; % o un valor por defecto
                else
                    dataES(fila,i) = dataES(fila,i-1);
                end
            end
        end
    end

    % Sumar la fila 3 corregida
    sumaPrecioMedio = sum(dataES(3,:))/8760;

end
