function [P_mode_vapor, P_mode_elec, E_vapor] = DEMANDA_BUGADERIA(Cap_real)

% Definición de variables
Bugad_P_melec = 9.4 + 1.79 + 12.37; % Potencia eléctrica total (kW)
Bugad_P_mvap = 1.1 + 0.79 + 0.4;    % Potencia de vapor total (kW)
Bugad_Q_vapor = 8.5 + 53 + 14;      % Calor de vapor total (kW)
Bugad_capac = 13;                   % Capacidad
Bugad_Roba_hoste = 1.5;             % Kg de ropa por día

% Curva de uso diaria
Bugad_curva_uso_diaria = [0, 0, 0, 0, 0, 0, 0, 0.5, 1, 1, 1, 1, 1, 1, 0.5, 0, 0, 0, 0, 0, 0, 0, 0, 0];
Bugad_curva_uso_anual = repmat(Bugad_curva_uso_diaria(:), 365, 1);
Bugad_curva_uso_anual = Bugad_curva_uso_anual(:);

Cap_real_horas = repelem(Cap_real, 24); % Replicamos cada valor diario 24 veces
Cap_real_horas = Cap_real_horas(:);


Bugad_GC = (Cap_real_horas .* Bugad_Roba_hoste .* Bugad_curva_uso_anual) / (Bugad_capac * sum(Bugad_curva_uso_diaria));

% Cálculo de energía
P_mode_vapor = Bugad_GC .* Bugad_P_mvap; % Vector de 8760 horas
P_mode_elec = Bugad_GC .* Bugad_P_melec; % Vector de 8760 horas
E_vapor = Bugad_GC .* Bugad_Q_vapor; % Vector de 8760 horas

% Verificar que las salidas tienen 8760 valores
%% Gráficos
% Figura 1: Gráfico de E_mode_vapor y E_mode_elec
figure; % Crear la figura
hold on;
plot(1:length(P_mode_elec), P_mode_elec, '-r', 'DisplayName', 'Energía elèctrica (kWh)'); % Línea roja continua
hold off;
xlabel('Hores de l''any');
ylabel('Energía (kWh)');
title('Consum d''electricitat bugaderia');
grid on;


end

