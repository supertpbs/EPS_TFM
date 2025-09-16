function [Cost_optim,Emi_optim] = OPTIMITZACIO_SISTEMA(Cost_hor,Emissions_hor)

[Cost_optim, Mode_opt_cost] = min(Cost_hor, [], 2); % vector horari amb mode òptim (1..4)
[Emi_optim, Mode_opt_Emi] = min(Emissions_hor, [], 2);


mesos_idx = reshape(repmat(1:12, 730, 1), [], 1); % GRAFICA MODE COST OPTIM
ind_modes = bsxfun(@eq, Mode_opt_cost, 1:5);
freq_per_mode_mes = zeros(12, 5);
for j = 1:5
    freq_per_mode_mes(:, j) = accumarray(mesos_idx, ind_modes(:, j), [12 1]);
end
freq_per_mode_mes_pct = freq_per_mode_mes ./ 730 * 100;% Convertim a percentatges mensuals
configurarGrafica(12) % Fem el barplot apilat
bar(freq_per_mode_mes_pct, 'stacked')
ylabel('Percentatge de temps [%]')
title('Distribució percentual mensual dels modes d''operació(optimització cost)')
legend(arrayfun(@(x) sprintf('Mode %d', x), 1:5, 'UniformOutput', false), 'Location', 'best')
xlim([0.4 12.6]);
ylim([0 110]);
grid off


ind_modes = bsxfun(@eq, Mode_opt_Emi, 1:5); % GRAFICA OPTIM EMISIONS
freq_per_mode_mes = zeros(12, 5);
for j = 1:5
    freq_per_mode_mes(:, j) = accumarray(mesos_idx, ind_modes(:, j), [12 1]);
end
freq_per_mode_mes_pct = freq_per_mode_mes ./ 730 * 100;% Convertim a percentatges mensuals
configurarGrafica(12)% Fem el barplot apilat
bar(freq_per_mode_mes_pct, 'stacked')
ylabel('Percentatge de temps [%]')
title('Distribució percentual mensual dels modes d''operació(optimització emisions)')
legend(arrayfun(@(x) sprintf('Mode %d', x), 1:5, 'UniformOutput', false), 'Location', 'best')
grid on

%% emisions per mode
configurarGrafica(12);        %grafic consum gasoil per mode
bar(Emissions_hor, 'grouped');
ylabel('Emisions [Ton. CO2]');
title('Emisions per mode');
xlim([0.4 12.6])
%ylim([15000 35000])
legend(compose('Mode %d', 1:5), 'Location', 'bestoutside');


end