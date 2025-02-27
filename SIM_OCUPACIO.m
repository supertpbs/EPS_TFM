clc;
clear;
%% DADES
Cap_hostes_max=32;
Cap_variacio_mensual = [0, 0.3, 0.5, 0.65, 0.75, 0.87, 0.93, 0.95, 0.9, 0.75, 0.5, 0]; % Vector d'ocupació mensual (12 mesos)
Cap_variacio_setmanal = [0.9, 1.1, 1.0, 1.0, 1.0, 1.1, 1.1]; % Vector de variació setmanal (7 dies)


Cap_variacio_setmanal= (Cap_variacio_setmanal / sum(Cap_variacio_setmanal)) * 7;    %normalitzem la variació
Cap_variacio_setmanal_anual = repmat(Cap_variacio_setmanal, 1, 53); % 52 setmanes
Cap_variacio_mensual_expandida = repelem(Cap_variacio_mensual, 31, 1);
Cap_real = Cap_hostes_max * Cap_variacio_mensual_expandida(1:365) .* Cap_variacio_setmanal_anual(1:365);


figure;
plot(1:365, Cap_real, 'LineWidth', 2);
ylabel('Ocupació Real');
title('Ocupació Real Diària deHotel');
grid on;
xlim([1 365]); % Limitar l'eix X a 365 dies
xticks(0:31:365); % Marcar els mesos cada 30 dies
xticklabels({'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'});
xlabel('Mesos');