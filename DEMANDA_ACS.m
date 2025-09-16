function E_ACS = DEMANDA_ACS(Cap_real,T_ACS,L_pers,Long_canonades,D_coef_ruido)
 %% CALCUL ENERGIA DIARIA
    T_XARXA = [11, 11, 12, 13, 15, 18, 20, 20, 19, 17, 14, 12];    %temperatura d'aigua de xarxa
    T_AFCH = interp1(linspace(1, 365, 12), T_XARXA, 1:365, 'spline');

    D_ACS = L_pers*Cap_real .* (60 - T_AFCH) ./ (T_ACS - T_AFCH);   %correccio de demanda corregida per temperatura
    E_perdues=Long_canonades*(3.9+5.9+7.9)/3;   %perdues en W
    E_ACS_diaria=(D_ACS.*(T_ACS-T_AFCH)*1.16+E_perdues)/1000;       %Energia necesaria para reponer ACS en kWh


%% CALCUL MINUTS PUNTA
    %Q_t = 15.37;     % Caudal teórico [L/min]
    %A = 1.080; B = 0.5; C = -1.830;
    %Q_c = A * Q_t^B + C;     % Caudal crítico [L/min]
    %Minutos_punta_dia = D_ACS ./ Q_c ./ 60;   % min/día

%% Expandir
    t = 0:1:23;  % hores del dia    
    phi = 0.3*exp(-(t-8).^2/6) + 0.2*exp(-(t-14).^2/4) + 0.5*exp(-(t-20).^2/5);
    phi = (phi / sum(phi))+D_coef_ruido;  % Normalitzar a 1 i afegir renou
    %E_ACS = reshape(E_ACS_diaria(:) * phi, [], 1);
    E_ACS_horaria = E_ACS_diaria(:) * phi;  % Resultat: 365×24
    E_ACS = reshape(E_ACS_horaria', [], 1); 
%% visualizar
    configurarGrafica(8760);
    plot(E_ACS);
    title('Demanda d''ACS horaria anual');
    ylabel('Demanda tèrmica [kWh]');

    configurarGrafica(0);
    plot(phi.*100);
    title('Perfil de consum diari d''ACS')
    xlim([0 24]);
    xticks(0:4:24);
    ylabel('% del consum diari');
    xlabel('Hores del dia');

end
