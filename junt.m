clc
clear

%% DADES
D_coef_ruido = 0.05;      % Generar ruido uniforme entre -5% i +5%

D_Cap_variacio_mensual = [0, 0.3, 0.4, 0.75, 0.85, 0.95, 1, 1, 0.9, 0.75, 0.5, 0]; % Vector de ocupación mensual
D_hores_obert = 8760*(12-sum(D_Cap_variacio_mensual == 0));
D_Cap_hostes_max = 62;

D_sup=7216.69;            %Superficie en m2
D_prev_ilum=15;            %W/m2

D_Long_canonades=100;
D_ACS_temp=65;            %Temperatura de consum
D_ACS_pers=80;            %70 litres per persona per dia

P_ilum = D_sup*D_prev_ilum/1000; %kW

E_elec_estandar_referencia = [8194, 50966, 64880, 59592, 60264, 58404, 72595, 75659, 70613, 112895, 103149, 6033];   %consum en kwh

%% CALCUL CAPACITAT

Cap_real = GENERAR_OCUPACIO(D_Cap_hostes_max, D_Cap_variacio_mensual,D_coef_ruido);

%% CALCUL DEMANDES
Q_ACS = DEMANDA_ACS(Cap_real,D_ACS_temp,D_ACS_pers,D_Long_canonades,D_coef_ruido);      % energia ACS en kWh

    
E_ilum = DEMANDA_ILUM(P_ilum, Cap_real, D_Cap_hostes_max,D_coef_ruido);
[E_mode_vapor, E_bugad, E_vapor] = DEMANDA_BUGADERIA(Cap_real);
E_varios = E_ilum*0.5+20;
E_aux=E_varios+E_bugad;



[Q_CLIMA_CALOR,Q_CLIMA_FRED,T_ext] = DEMANDA_CLIMA(Cap_real, E_aux, E_ilum);   %demandes termiques clima en kwh.



%% CALCUL SISTEMA
E_elec=E_ilum+E_aux;
[E_ACS,E_CALEF,E_REFRIG,P_GRUPO,Consum_elec,Litres] = SIMULACIO_SISTEMA(Q_CLIMA_CALOR,Q_ACS,Q_CLIMA_FRED, E_elec,T_ext);


DEMANDA_ELEC(E_bugad, E_varios, E_ilum, E_ACS, E_CALEF, E_REFRIG);

%% CALCUL ECONOMIC i IMPACTE
[Cost_hor,Emissions_hor] = SIMULACIO_ECONOMICA(Consum_elec,Litres);



%% VALIDACIÓ DEL MODEL
    configurarGrafica(12);
    plot(E_elec_estandar_referencia, 'Color', [0 0.4470 0.7410], 'LineWidth', 1);
    Consum_simulacio = sum(reshape(Consum_elec(:,1), 730, 12));
    plot(Consum_simulacio, 'Color', 'r', 'LineWidth', 1);

P1 = E_ilum ./ Consum_elec(:,1) * 100;  %grafic percentatge diferents usos
P2 = E_varios ./ Consum_elec(:,1) * 100;
P3 = (Consum_elec(:,1) - E_varios - E_ilum) ./ Consum_elec(:,1) * 100;
P = [P1, P2, P3];
configurarGrafica(8760)
area(P);
ylim([0 100]);
ylabel('Percentatge (%)');
title('Consums elèctrics apilats en %');
legend({'Il·luminació', 'Auxiliars', 'Clima'}, 'Location', 'best');
grid on;



