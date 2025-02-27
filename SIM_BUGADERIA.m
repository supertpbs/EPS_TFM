
% Definición de variables
Bugad_P_melec = 9.4 + 1.79 + 12.37; % Potencia eléctrica total (kW)
Bugad_P_mvap = 1.1 + 0.79 + 0.4;    % Potencia de vapor total (kW)
Bugad_Q_vapor = 8.5 + 53 + 14;      % Calor de vapor total (kW)
Bugad_capac = 13;                   % Capacidad
Bugad_Roba_hoste = 1.5;             % Kg de ropa por día

% Curva de uso diaria
Bugad_curva_uso_diaria = [0, 0, 0, 0, 0, 0, 0, 0.5, 1, 1, 1, 1, 1, 1, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0];


Bugad_curva_uso_anual = repmat(Bugad_curva_uso_diaria(:), ceil(365 / length(Bugad_curva_uso_diaria)), 1); 
Cap_real_horas = repelem(Cap_real, 24); % Replicamos cada valor diario 24 veces
Bugad_GC = (Cap_real_horas .* Bugad_Roba_hoste) / (Bugad_capac * sum(Bugad_curva_uso_diaria)); 

% Cálculo de energía
E_mode_vapor = Bugad_GC .* Bugad_P_mvap; % Vector de 8760 horas
E_mode_elec = Bugad_GC .* Bugad_P_melec; % Vector de 8760 horas
Q_vapor = Bugad_GC .* Bugad_Q_vapor; % Vector de 8760 horas

% Verificar que las salidas tienen 8760 valores
disp(['E_mode_vapor tiene ', num2str(length(E_mode_vapor)), ' valores']);
disp(['E_mode_elec tiene ', num2str(length(E_mode_elec)), ' valores']);
disp(['Q_vapor tiene ', num2str(length(Q_vapor)), ' valores']);

%% Gráficos
figure;

% Gráfico de E_mode_vapor y E_mode_elec
subplot(2, 1, 1); % Crear dos gráficos en uno
hold on;
plot(1:length(E_mode_vapor), E_mode_vapor , 'b', 'DisplayName', 'Energía de vapor (kWh)');
plot(1:length(E_mode_elec), E_mode_elec, 'r', 'DisplayName', 'Energía eléctrica (kWh)');
hold off;
xlabel('Horas del año');
ylabel('Energía (kWh)');
title('Consumo de Energía Diaria');
grid on;

% Gráfico de Q_vapor
subplot(2, 1, 2);
plot(1:length(Q_vapor), Q_vapor, 'g', 'DisplayName', 'Calor de vapor (kWh)');
xlabel('Horas del año');
ylabel('Calor (kWh)');
title('Calor de Vapor Diario');
grid on;
