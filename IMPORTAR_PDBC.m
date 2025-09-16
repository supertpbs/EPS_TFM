function [preciosES, precioMedio] = IMPORTAR_PDBC(carpeta)
% Importa archivos marginalpdbc_YYYYMMDD.1 de una carpeta
% Devuelve vector fila de precios, vector fila de fechas/hora y precio medio anual
% Comprueba que cada archivo tiene 24 horas y que hay 365 archivos

    filesList = dir(fullfile(carpeta, 'marginalpdbc_*.1'));
    if numel(filesList) ~= 365
        error('Se esperaban 365 archivos, pero hay %d.', numel(filesList));
    end

    % Ordenar archivos por nombre (fecha)
    [~, idx] = sort({filesList.name});
    filesList = filesList(idx);

    preciosAll = [];
    timesAll = datetime.empty(0,1);

    for k = 1:numel(filesList)
        fname = fullfile(filesList(k).folder, filesList(k).name);
        fid = fopen(fname, 'r');
        if fid < 0
            error('No se pudo abrir el archivo %s.', fname);
        end

        preciosDia = nan(1,24);
        horasLeidas = 0;

        while ~feof(fid)
            ln = strtrim(fgetl(fid));
            if ~ischar(ln) || isempty(ln), continue; end
            if startsWith(ln, 'MARGINALPDBC', 'IgnoreCase', true), continue; end
            if startsWith(ln, '*'), continue; end

            tokens = strsplit(ln, ';');
            tokens = tokens(~cellfun('isempty', tokens));
            if numel(tokens) < 5, continue; end

            y = str2double(tokens{1});
            mo = str2double(tokens{2});
            dday = str2double(tokens{3});
            h = str2double(tokens{4});
            p = str2double(strrep(tokens{5}, ',', '.'));

            if h < 1 || h > 24
                fclose(fid);
                error('Hora inválida %d en archivo %s.', h, filesList(k).name);
            end

            preciosDia(h) = p;
            horasLeidas = horasLeidas + 1;
        end
        fclose(fid);

        if any(isnan(preciosDia))
            error('Faltan horas en el archivo %s.', filesList(k).name);
        end
        if horasLeidas ~= 24
            error('El archivo %s no tiene 24 horas, tiene %d.', filesList(k).name, horasLeidas);
        end

        % Crear vector datetime para el día
        fechaDia = datetime(y, mo, dday, 0, 0, 0) + hours(0:23);

        preciosAll = [preciosAll, preciosDia];
        timesAll = [timesAll; fechaDia'];
    end

    % Ya están ordenados por día y hora
    preciosES = preciosAll;
    t = timesAll';

    % Comprobar total horas esperadas
    yr = year(t(1));
    daysInYear = days(datetime(yr+1,1,1) - datetime(yr,1,1));
    expectedHours = daysInYear * 24;
    if numel(preciosES) ~= expectedHours
        error('Se esperaban %d horas, pero se importaron %d.', expectedHours, numel(preciosES));
    end

    % Rellenar NaN (por si acaso) con valor anterior (o cero si es el primero)
    for i = 1:numel(preciosES)
        if isnan(preciosES(i))
            if i == 1
                preciosES(i) = 0;
            else
                preciosES(i) = preciosES(i-1);
            end
        end
    end

    % Calcular precio medio anual
    precioMedio = mean(preciosES);

end

