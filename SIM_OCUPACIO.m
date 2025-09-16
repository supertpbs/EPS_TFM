clc;
clear;
%% DADES ENTRADA
Cap_hostes_max=32;
Cap_variacio_mensual = [0, 0.5, 0.6, 0.75, 0.85, 0.95, 1, 1, 0.9, 0.75, 0.5, 0]; % Vector d'ocupació mensual (12 mesos)
Cap_variacio_setmanal = [0.9, 1.1, 1.0, 1.0, 1.0, 1.1, 1.1]; % Vector de variació setmanal (7 dies)


Cap_variacio_setmanal= (Cap_variacio_setmanal / sum(Cap_variacio_setmanal)) * 7;    %normalitzem la variació
Cap_variacio_setmanal_anual = repmat(Cap_variacio_setmanal, 1, 53); % 52 setmanes

%Cap_variacio_mensual_expandida = repelem(Cap_variacio_mensual, 31, 1);
dies_mesos = linspace(1, 365, 12);
idx_no_zero = Cap_variacio_mensual ~= 0
dies_mesos_no_zero = dies_mesos(idx_no_zero);
valors_no_zero = Cap_variacio_mensual(idx_no_zero);
Cap_variacio_mensual_suau = interp1(dies_mesos_no_zero, valors_no_zero,  1:365, 'pchip', 0);
%Cap_variacio_mensual_suau = interp1(dies_mesos, Cap_variacio_mensual, 1:365, 'pchip'); % 'pchip' o 'spline'

Cap_real = Cap_hostes_max * Cap_variacio_mensual_suau(1:365) .* Cap_variacio_setmanal_anual(1:365);




%% Grafic ocupació
figure;
plot(1:365, Cap_real, 'LineWidth', 2);
ylabel('Ocupació (pax)');
title('Ocupació diària');
grid on;
xlim([1 365]); % Limitar l'eix X a 365 dies
xticks(0:31:365); % Marcar els mesos cada 30 dies
xticklabels({'Gener', 'Febrer', 'Març', 'Abril', 'Maig', 'Juny', 'Juliol', 'Agost', 'Setembre', 'Octubre', 'Novembre', 'Desembre'});
xlabel('Mesos');
