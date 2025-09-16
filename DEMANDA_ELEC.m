function DEMANDA_ELEC(E_bugad, E_aux, E_ilum, E_ACS, E_CALEF, E_REFRIG)


E_all = [E_aux(:), E_bugad(:), E_ACS(:), E_ilum(:), E_REFRIG(:), E_CALEF(:)]; % ordre coherent amb la llegenda

configurarGrafica(8760);
plot(E_ACS+E_CALEF+E_REFRIG);
title("Consum elèctric combinat de producció d'HVAC i ACS")
ylabel("kwh")

configurarGrafica(8760);
plot(E_ilum+E_aux+E_bugad);
title("Consum elèctric combinat de producció de càrregues d'iluminació, auxiliars i de bugaderia")
ylabel("kwh")


hores_mes = 730;   % simplificació: 12 mesos iguals
n_mesos   = 12;

% --- Gràfic horari total ---
configurarGrafica(8760);
plot(sum(E_all,2));                         % suma de totes les sèries
xlabel('Hores de l''any');
ylabel('Energia horària [kWh]');            % si són energies/interval (kWh per hora)
title('Demanda elèctrica horària total');
grid on;

% --- Sumes mensuals vectoritzades (12x6) ---
E_month = reshape(E_all, hores_mes, n_mesos, 6);  % 730 x 12 x 6
E_mes   = squeeze(sum(E_month, 1));               % 12 x 6

% --- Percentatges per mes ---
E_mes_pct = E_mes ./ sum(E_mes,2) * 100;          % cada fila (mes) suma 100%

% --- Barplot apilat mensual en %
configurarGrafica(12);
bar(E_mes_pct, 'stacked');
set(gca,'XTick',1:12,'XTickLabel',{'Gen','Feb','Mar','Abr','Mai','Jun','Jul','Ago','Set','Oct','Nov','Des'});
xlabel('Mesos');
ylabel('Repartiment energia (%)');
legend({'Auxiliars','Bugaderia','ACS','Il·luminació','Refrigeració','Calefacció'}, 'Location','eastoutside');
title('Distribució mensual percentual d''energia');
xlim([0.4 12.4]);
ylim([0 100]);
grid on;

end