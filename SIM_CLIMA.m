function    [E_CLIMA_CALOR,E_CLIMA_FRED,T_ext] = SIM_CLIMA(Cap_real, E_varios, E_ilum)
%% constants
    rho_aire=1.204;     %kg/m3
    cp_aire=1.006;       %kJ/kg·K
    F_c_solar=0.05;
    F_c_ombra=0.1;
    F_vidre=1;
    Q_sens_pers = [repmat(50, 1, 9), repmat(75, 1, 15)];
    Q_sens_pers_horari = repmat(Q_sens_pers, 1, 365);
    Q_sens_pers_horari = Q_sens_pers_horari(:);
    Q_lat_pers = [repmat(25, 1, 9), repmat(55, 1, 15)];
    Q_lat_pers_horari = repmat(Q_lat_pers, 1, 365);
    Q_lat_pers_horari = Q_lat_pers_horari(:);
    Cap_real_horari = interp1(1:365, Cap_real, linspace(1, 365, 8760), 'linear');
    Cap_real_horari    = Cap_real_horari(:);


%% DADES CONTRORN
    T_int=23;
    W_int=0.5;
    [T_ext, W_ext] = IMPORTAR_METEO('TMY.csv');
    T_media=mean(T_ext);
    T_suelo =0.0068*T_media^2+T_media*0.963+0.6865;

    %valors de radiació de l'indret.
    R_Nord = IMPORTAR_RADIAC('R_NORTE.csv');
    R_Sur  = IMPORTAR_RADIAC('R_SUR.csv');
    R_Est  = IMPORTAR_RADIAC('R_ESTE.csv');
    R_Oest = IMPORTAR_RADIAC('R_OESTE.csv');
    R_vertical = IMPORTAR_RADIAC('R_FLAT.csv');
    
    %% Visualització dades Radiació per orientació
    hores_per_mes = 730;  % Suposant 12 mesos iguals
    R_Nord_mensual   = zeros(1,12);
    R_Sud_mensual    = zeros(1,12);
    R_Est_mensual    = zeros(1,12);
    R_Oest_mensual   = zeros(1,12);
    R_Horitz_mensual = zeros(1,12);
    for i = 1:12
    idx = (i-1)*hores_per_mes + 1 : i*hores_per_mes;
        R_Nord_mensual(i)   = sum(R_Nord(idx));
        R_Sud_mensual(i)    = sum(R_Sur(idx));
        R_Est_mensual(i)    = sum(R_Est(idx));
        R_Oest_mensual(i)   = sum(R_Oest(idx));
        R_Horitz_mensual(i) = sum(R_vertical(idx));
    end
    % Dibuixar barres apilades

    configurarGrafica(12);
    bar([R_Nord_mensual; R_Sud_mensual; R_Est_mensual; R_Oest_mensual; R_Horitz_mensual]', 'grouped');
    legend({'Nord', 'Sud', 'Est', 'Oest', 'Horitzontal'});
    title('Radiació solar mensual per orientació');
    ylabel('Radiació mensual [Wh/m²]');

    %% Definició rangs de comfort
    t = linspace(0, 1, 8760)-0.25;  % Normalitzat a l'any (0: gener, 1: desembre)
    T_max = 24 + 1 * sin(2 * pi * t);  % Oscil·lació suau
    T_min = 22 + 1 * sin(2 * pi * t);  
    W_max = 55 + 5 * sin(2 * pi * t);  % Oscil·lació suau
    W_min = 42.5 + 2.5 * sin(2 * pi * t);  

    %% Visualització dades Temperatura 
    configurarGrafica(8760);
    plot(T_ext, 'Color', [0 0.4470 0.7410], 'LineWidth', 1);  % Blau estilitzat
    yline(T_int, 'Color', [0 0.6 0], 'LineWidth', 1.5, 'LineStyle', '--'); % Verd
    plot(T_max, 'Color', [0.85 0.33 0.1], 'LineWidth', 1, 'LineStyle', ':');  % Confort(taronja)
    plot(T_min, 'Color', [0.85 0.33 0.1], 'LineWidth', 1, 'LineStyle', ':');  %  Confort(taronja)
    ylabel('Temperatura exterior (°C)');
    title('Perfil anual de temperatura exterior i franges de confort');
    legend({'T\_ext', 'T\_int', 'Rang de comfort'}, 'Location', 'best');

%% Visualització dades humitat

    configurarGrafica(8760);
    plot(W_ext, 'Color', [0 0.4470 0.7410], 'LineWidth', 1);  % Blau estilitzat
    yline(W_int*100, 'Color', [0 0.6 0], 'LineWidth', 1.5, 'LineStyle', '--'); % Verd
    plot(W_max, 'Color', [0.85 0.33 0.1], 'LineWidth', 1, 'LineStyle', ':');  % Confort(taronja)
    plot(W_min, 'Color', [0.85 0.33 0.1], 'LineWidth', 1, 'LineStyle', ':');  %  Confort(taronja)
    ylim([0 109]); 
    ylabel('Humitat relativa (%)');
    title('Perfil anual d''humitat relativa exterior i franges de confort');
    legend({'W\_ext', 'W\_int', 'Rang de confort'}, 'Location', 'best');

%% DADES EDIFICI
%Transmitancies
U_p_eda=1.36;
U_p_eda_sot=1.29;
U_suelo=0.85;
U_techo_eda=2.11;
U_techo_suites=1.07;
U_techo_spa=1.61;
U_p_suites=0.55;
U_vidre=2.79;
U_portes=2.55;

%Cabal de renovació de l'edifici
V_renov=28656.3;      %m3/h totals

S_p_eda_N=392.91;
S_p_eda_S=4333.51;
S_p_eda_O=357.97;
S_p_eda_E=363.14;
S_p_suites_N=99.18;
S_p_suites_S=131.65;
S_p_suites_E=71.10;
S_p_suites_O=173.8;
S_vidre_N=20.16;
S_vidre_S=29.34;
S_vidre_E=14.935;
S_vidre_O=20.6309;
S_portes_N=8.93;
S_portes_S=5.26;
S_portes_E=4.61;
S_portes_O=5.74;
S_techo_spa=245.5;
S_techo_suites=349.7;
S_techo_eda=1037.75;
S_suelo_eda=1037.75;
S_suelo_suites=340.7;
S_suelo_spa=245.5;
S_p_eda_sot=194.52;

%% Calcul calor sensible
    %Transmissió
Q_st_N = (U_p_eda*S_p_eda_N+U_p_suites*S_p_suites_N+U_vidre*S_vidre_N+U_portes*S_portes_N).*(T_ext-T_int);
Q_st_S = (U_p_eda*S_p_eda_S+U_p_suites*S_p_suites_S+U_vidre*S_vidre_S+U_portes*S_portes_S).*(T_ext-T_int);
Q_st_E = (U_p_eda*S_p_eda_E+U_p_suites*S_p_suites_E+U_vidre*S_vidre_E+U_portes*S_portes_E).*(T_ext-T_int);
Q_st_O = (U_p_eda*S_p_eda_O+U_p_suites*S_p_suites_O+U_vidre*S_vidre_O+U_portes*S_portes_O).*(T_ext-T_int);
Q_st_suelo=(U_suelo*(S_suelo_eda+S_suelo_suites+S_suelo_spa)+U_p_eda_sot*S_p_eda_sot).*(T_suelo-T_int);
Q_st_techo=U_techo_eda*S_techo_eda+U_techo_suites*S_techo_suites+U_techo_spa*S_techo_spa.*(T_ext-T_int);
Q_st =Q_st_N+Q_st_E+Q_st_O+Q_st_S+Q_st_techo+Q_st_suelo; 

    %Radiació OPACS
Q_R_N=R_Nord*(S_p_eda_N+S_p_suites_N+S_portes_N)*F_c_solar*(1-F_c_ombra);
Q_R_S=R_Sur*(S_p_eda_S+S_p_suites_S+S_portes_S)*F_c_solar*(1-F_c_ombra);
Q_R_E=R_Est*(S_p_eda_E+S_p_suites_E+S_portes_E)*F_c_solar*(1-F_c_ombra);
Q_R_O=R_Oest*(S_p_eda_O+S_p_suites_O+S_portes_O)*F_c_solar*(1-F_c_ombra);
Q_R_V=R_vertical*(S_techo_eda+S_techo_suites+S_techo_spa)*F_c_solar*(1-F_c_ombra);
Q_sr_o=(Q_R_N+Q_R_O+Q_R_E+Q_R_S+Q_R_V)./1000;

    %Radiació TRANSPARENTS
Q_sr_v = (S_vidre_N*R_Nord+S_vidre_S*R_Sur+S_vidre_E*R_Est+S_vidre_O*R_Oest)*F_vidre;

    %Renovació
Q_si =V_renov*rho_aire*cp_aire.*(T_ext-T_int)./3600;

    %Carregues interiors
Q_sil =E_ilum;
Q_sv = E_varios*0.75;
Q_sp = Cap_real_horari.*Q_sens_pers_horari/1000;

Q_sensible = Q_sr_v+Q_sr_o+Q_st+Q_si+Q_sil+Q_sv+Q_sp;

%% Calcul calor latent
Q_li=V_renov*rho_aire.*(W_ext./100-W_int);
Q_lp=Cap_real_horari.*Q_lat_pers_horari;
Q_latent = Q_li+Q_lp;

%% Calculo total
    coef_seg=1.04;

    E_CLIMA_CALOR=coef_seg.*max(0,-Q_sensible)./1000;    %no es te en compte el calor latent per a calefacció
    E_CLIMA_FRED=coef_seg.*max(0,(Q_sensible + Q_latent))./1000;   
%% Visualització
    configurarGrafica(8760);
    plot(E_CLIMA_FRED, 'b', 'LineWidth', 1);
    ylabel('Demanda térmica (kW)');
    title('Demanda horaria de refrigeració');

    configurarGrafica(8760);
    plot(E_CLIMA_CALOR, 'r', 'LineWidth', 1);
    ylabel('Demanda térmica (kW)');
    title('Demanda horaria de calefacció');

end
