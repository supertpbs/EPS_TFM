clc
clear

%% Cargar datos clima exterior
nombre_archivo = 'DATOS_TIEMPO.csv';
opts = detectImportOptions(nombre_archivo, 'VariableNamingRule', 'preserve');
opts.SelectedVariableNames = {'T2m', 'RH', 'G(h)', 'SP'};
datos = readtable(nombre_archivo, opts);
matriz_datos = table2array(datos);
matriz_datos = matriz_datos(1:8760, :);


%% Parámetros del edificio
A = 5000;       % Superficie del hotel en m² (ajustar)
U = 1.5;        % Coeficiente de pérdidas W/m²·K (ajustar)
V_dot = 2000;   % Caudal de aire fresco en m³/h (ajustar)

% Parámetros de renovación de aire
rho = 1.2;           % Densidad del aire en kg/m³
C_p = 1006;          % Capacidad calorífica del aire en J/kg·K
rho_agua = 1000;    % Densidad del agua en kg/m³
C_p_agua = 4186;    % Capacidad calorífica del agua en J/(kg·K)

% Definir rango horario para suavizar (24 horas)
n_horas = 24;

%% Cálculo
T_ext = matriz_datos(:, 1);     % Temperatura exterior (°C)
R_Solar= matriz_datos(:, 3);    % Radiación solar



num_horas = length(T_ext);
horas = (0:num_horas-1)'; % Crear un vector de horas
T_int_verano = 24; % Promedio entre 23-25°C
T_int_invierno = 22; % Promedio entre 21-23°C
meses = mod(floor(horas / 720), 12) + 1; % Aproximación: 720h = 30 días
T_int = T_int_verano * (meses >= 6 & meses <= 9) + T_int_invierno * (meses < 6 | meses > 9);

% Calcular la demanda térmica en cada hora
Q_conduccion = U * A * (T_int - T_ext); % Pérdidas por conducción en W
V_dot_m3s = V_dot / 3600; % Convertir a m³/s
Q_renovacion = V_dot_m3s * rho * C_p * (T_int - T_ext); % En W
Q_total = (Q_conduccion + Q_renovacion) / 1000; % En kWh

% Calefacción y refrigeración
Q_calef = max(0, Q_total); % Calefacción (demanda positiva) kWh
Q_refri = max(0, -Q_total); % Refrigeración (demanda positiva) kWh

%% Suavizar demanda 


%% Graficar los resultados

% Gráfico de necesidades de calefacción
figure('Units', 'inches', 'Position', [0, 0, 10, 4]);
hold on;
plot(Q_calef, 'r', 'DisplayName', 'Calefacció (kW)'); % Calefacción en rojo
xlabel('Hores del any');
ylabel('Demanda tèrmica (kW)');
title('Necessitats de calefacció');
legend show;
grid on;
hold off;

% Gráfico de necesidades de refrigeración
figure('Units', 'inches', 'Position', [0, 0, 10, 4]); 
hold on;
plot(Q_refri, 'b', 'DisplayName', 'Refrigeració (kW)'); % Refrigeración en azul
xlabel('Hores del any');
ylabel('Demanda tèrmica (kW)');
title('Necessitats de refrigeració');
legend show;
grid on;
hold off;


