%% ILUMINACIÓN PARAMETROS
sup=1000;   %m2
P_ilum = sup*15/1000;    %kW INSTALADOS
curva_uso = [0.75, 0.4, 0.25, 0.22, 0.21, 0.22, 0.25, 0.4, 0.6, 0.57, 0.5, 0.45, 0.5, 0.53, 0.5, 0.45, 0.41, 0.4, 0.47, 0.57, 0.7, 0.8, 0.8, 0.77];
curva_uso_anual = repmat(curva_uso(:), ceil(8760 / length(curva_uso)), 1);

% Calcular factor de reducción
factor_reduccion = max(0, 1 - (R_Solar / 1000) * 0.3); % Evitar valores negativos
potencia_necesaria = P_ilum * curva_uso_anual .* factor_reduccion; % Element-wise multiplication

%comparar horas verano-invierno
horas_verano = (152 * 24 + 1):(152 * 24 + 72); % Horas de verano
potencia_verano = potencia_necesaria(horas_verano);
horas_invierno = (336 * 24 + 1):(336 * 24 + 72); % Horas de invierno
potencia_invierno = potencia_necesaria(horas_invierno);
% Graficar las potencias necesarias
figure;
hold on;
plot(1:72, potencia_verano, 'b', 'LineWidth', 2, 'DisplayName', 'Verano (72h)'); % Verano en azul
plot(1:72, potencia_invierno, 'r', 'LineWidth', 2, 'DisplayName', 'Invierno (72h)'); % Invierno en rojo
xlabel('Horas del año');
ylabel('Potencia necesaria de iluminación (kW)');
title('Potencia Necesaria de Iluminación: Verano vs Invierno');
legend show;
grid on;
xlim([1 72]); % Limitar el eje X a 8760 horas
ylim([0 P_ilum]); % Limitar el eje Y entre 0 y P_ilum
hold off;