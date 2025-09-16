function [E_ACS,E_CALEF,E_REFRIG,P_GRUPO,Consum_elec,Litres] = SIMULACIO_SISTEMA(Q_CLIMA_CALOR,Q_ACS,Q_CLIMA_FRED, E_elec,T_ext)
    %% datos
    INFO_GC = [1, 0.7, 0.5];        % grau de carrega
    INFO_CONSUM = [42.1, 37.5, 24]; % l/h
    CORBA_CONSUM = polyfit(INFO_GC, INFO_CONSUM, 2);
    INFO_PGRUPO=160;    %potencia grup PRP en kw

    FRAC_TO_COOLANT=0.515209;   %kwh calor en funció de kwelectrics
    FRAC_TO_EXHAUST=0.69547;    %kwh calor en funció de kwelectrics
    COP_ABSORPTION=0.79;
 %   COP_ABSORPTION=0;
    EFF_INTERCAMBIADOR=0.95;
    
    Q_CLIMA_CALOR=Q_CLIMA_CALOR*1.1;
    Q_ACS=Q_ACS*1.1;
    Q_CLIMA_FRED=Q_CLIMA_FRED*1.1;
    E_elec=E_elec*1.1;
    PCI=43*0.84/3.6;        %PCI diesel en kwh/litre

    %% MODELADO BOMBAS CALOR
    P_B_CALOR=max(Q_CLIMA_CALOR*1.1);
    P_B_FRED=max(Q_CLIMA_FRED*1.1);
    P_B_ACS=max(Q_ACS*1.1);
    
    
    T_C_max=12;
    T_C_min=-10;
    T_F_max=60;
    T_F_min=20;
    T_A_max=7;
    T_A_min=-7;
    COP_C =polyfit([-7, 2, 7, 12], [2.6, 3.9, 5.8, 9.1], 2);
    COP_ACS = polyfit([-7, 2, 7], [1.4, 1.58 1.8], 2);
    COP_F= polyfit([35, 30, 25, 20], [3.0, 5.1, 9.2, 15.1], 2);
    
    Q_sobrant = zeros(8760,5);
    E_UTIL       = zeros(8760,5);

    %% MODE 1: grup APAGAT -> tot amb bombes/Grup apagat  ----------
    E_B_CALOR_1 = E_bomba(Q_CLIMA_CALOR, P_B_CALOR, COP_C,T_ext,T_C_min,T_C_max);
    E_B_FRED_1  = E_bomba(Q_CLIMA_FRED, P_B_FRED, COP_F,T_ext,T_F_min,T_F_max);
    E_B_ACS_1   = E_bomba(Q_ACS, P_B_ACS, COP_ACS,T_ext,T_A_min,T_A_max);
    P_GRUPO(:,1)= zeros(8760,1);
    Litres(:,1) = zeros(8760,1);
    Consum_elec(:,1) = E_elec + E_B_CALOR_1 + E_B_FRED_1 + E_B_ACS_1;         
    
    E_ACS=E_B_ACS_1;
    E_CALEF=E_B_CALOR_1;
    E_REFRIG=E_B_FRED_1;

    %% MODE 2: fora desaprofitar calor però grup sempre enmarxa  ----------
   Q_necesaria=(Q_ACS+Q_CLIMA_CALOR+Q_CLIMA_FRED/COP_ABSORPTION)/EFF_INTERCAMBIADOR;
   % Q_necesaria=(Q_ACS+Q_CLIMA_CALOR)/EFF_INTERCAMBIADOR;
    P_GRUPO(:,2)=Q_necesaria/(FRAC_TO_EXHAUST+FRAC_TO_COOLANT);
    gc(:,2) = min(1,max(P_GRUPO(:,2)/INFO_PGRUPO,0.5));
    P_GRUPO(:,2)=INFO_PGRUPO*gc(:,2);
    Q_recuperada=INFO_PGRUPO.*gc(:,2).*(FRAC_TO_EXHAUST+FRAC_TO_COOLANT);
    E_B_ACS   = E_bomba(max(0,Q_ACS-Q_recuperada), P_B_ACS, COP_ACS,T_ext,T_A_min,T_A_max);    
    E_B_CALOR = E_bomba(max(0,Q_CLIMA_CALOR-max(0,Q_recuperada-Q_ACS)), P_B_CALOR, COP_C,T_ext,T_C_min,T_C_max);
    E_B_FRED  = E_bomba(max(0,Q_CLIMA_FRED-max(0,(Q_recuperada-Q_ACS-Q_CLIMA_CALOR)*COP_ABSORPTION)),  P_B_FRED,  COP_F,T_ext,T_F_min,T_F_max);

    Litres(:,2) = polyval(CORBA_CONSUM, gc(:,2));
    Consum_elec(:,2) = E_elec + E_B_CALOR + E_B_FRED + E_B_ACS-P_GRUPO(:,2);  

    Q_sobrant(:,2)=max(0,(Q_recuperada-Q_ACS-Q_CLIMA_CALOR-Q_CLIMA_FRED*COP_ABSORPTION)); 
    E_UTIL(:,2)=(abs(P_GRUPO(:,2))+Q_recuperada-Q_sobrant(:,2));


    %% MODE 3: autoconsum si es posible, amb les bombes apagades si es possible , grup sempre enmarxa ----------
    Q_necesaria=(Q_ACS+Q_CLIMA_CALOR+Q_CLIMA_FRED/COP_ABSORPTION)/EFF_INTERCAMBIADOR;
    P_GRUPO(:,3)=max(E_elec,Q_necesaria/(FRAC_TO_EXHAUST+FRAC_TO_COOLANT));
    gc(:,3) = min(1,max(P_GRUPO(:,3)/INFO_PGRUPO,0.5));
    P_GRUPO(:,3)=INFO_PGRUPO*gc(:,3);
    Q_recuperada=INFO_PGRUPO.*gc(:,3).*(FRAC_TO_EXHAUST+FRAC_TO_COOLANT);
    E_B_ACS   = E_bomba(max(0,Q_ACS-Q_recuperada), P_B_ACS, COP_ACS,T_ext,T_A_min,T_A_max);    
    E_B_CALOR = E_bomba(max(0,Q_CLIMA_CALOR-max(0,Q_recuperada-Q_ACS)), P_B_CALOR, COP_C,T_ext,T_C_min,T_C_max);
    E_B_FRED  = E_bomba(max(0,Q_CLIMA_FRED-max(0,(Q_recuperada-Q_ACS-Q_CLIMA_CALOR)*COP_ABSORPTION)),  P_B_FRED,  COP_F,T_ext,T_F_min,T_F_max);


    Litres(:,3) = polyval(CORBA_CONSUM,gc(:,3));
    Consum_elec(:,3) = E_elec + E_B_CALOR + E_B_FRED + E_B_ACS-P_GRUPO(:,3);         
    Q_sobrant(:,3)=max(0,(Q_recuperada-Q_ACS-Q_CLIMA_CALOR-Q_CLIMA_FRED*COP_ABSORPTION)); 
    E_UTIL(:,3)=(abs(P_GRUPO(:,3))+Q_recuperada-Q_sobrant(:,3));

    %% MODE 4: grup al minim, sempre enmarxa  ----------
    gc(:,4) = ones(8760,1)*0.5;
    Q_recuperada=INFO_PGRUPO.*gc(:,4).*(FRAC_TO_EXHAUST+FRAC_TO_COOLANT);
    E_B_ACS   = E_bomba(max(0,Q_ACS-Q_recuperada), P_B_ACS, COP_ACS,T_ext,T_A_min,T_A_max);    
    E_B_CALOR = E_bomba(max(0,Q_CLIMA_CALOR-max(0,Q_recuperada-Q_ACS)), P_B_CALOR, COP_C,T_ext,T_C_min,T_C_max);
    E_B_FRED  = E_bomba(max(0,Q_CLIMA_FRED-max(0,(Q_recuperada-Q_ACS-Q_CLIMA_CALOR)*COP_ABSORPTION)),  P_B_FRED,  COP_F,T_ext,T_F_min,T_F_max);
    P_GRUPO(:,4)= INFO_PGRUPO.*gc(:,4);
    Litres(:,4) = polyval(CORBA_CONSUM, gc(:,4));
    Consum_elec(:,4) = E_elec + E_B_CALOR + E_B_FRED + E_B_ACS-INFO_PGRUPO*gc(:,4); 
    Q_sobrant(:,4)=max(0,(Q_recuperada-Q_ACS-Q_CLIMA_CALOR-Q_CLIMA_FRED*COP_ABSORPTION)); 
    E_UTIL(:,4)=(abs(P_GRUPO(:,4))+Q_recuperada-Q_sobrant(:,4));

    %% MODE 5: grup al màxim, sempre enmarxa  ----------
    gc(:,5) = ones(8760,1);
    Q_recuperada=INFO_PGRUPO.*gc(:,5).*(FRAC_TO_EXHAUST+FRAC_TO_COOLANT);
    E_B_ACS   = E_bomba(max(0,Q_ACS-Q_recuperada), P_B_ACS, COP_ACS,T_ext,T_A_min,T_A_max);    
    E_B_CALOR = E_bomba(max(0,Q_CLIMA_CALOR-max(0,Q_recuperada-Q_ACS)), P_B_CALOR, COP_C,T_ext,T_C_min,T_C_max );
    E_B_FRED  = E_bomba(max(0,Q_CLIMA_FRED-max(0,(Q_recuperada-Q_ACS-Q_CLIMA_CALOR)*COP_ABSORPTION)),  P_B_FRED,  COP_F,T_ext,T_F_min,T_F_max);  
    P_GRUPO(:,5)= INFO_PGRUPO.*gc(:,5);
    Litres(:,5) = polyval(CORBA_CONSUM, gc(:,5));
    Consum_elec(:,5) = E_elec + E_B_CALOR + E_B_FRED + E_B_ACS-INFO_PGRUPO*gc(:,5); 
    Q_sobrant(:,5)=max(0,(Q_recuperada-Q_ACS-Q_CLIMA_CALOR-Q_CLIMA_FRED*COP_ABSORPTION)); 
    E_UTIL(:,5)=(abs(P_GRUPO(:,5))+Q_recuperada-Q_sobrant(:,5));

%% GRAFIC FUE
    FUE = sum(E_UTIL,1) ./ sum(Litres .* PCI,1);
    FUEmax =max( E_UTIL./(Litres .* PCI), [], 1);
    T = array2table(FUE,'VariableNames', {'Mode1','Mode2','Mode3','Mode4','Mode5'});
    disp(T)
    Tmax = array2table(FUEmax,'VariableNames', {'Mode1','Mode2','Mode3','Mode4','Mode5'});
    disp(Tmax)
%% Grafics


configurarGrafica(8760);        %grafic potencia grup electrogen per mode
plot(1:8760, P_GRUPO(:,1), '-', 'LineWidth', 1.5);
plot(1:8760, P_GRUPO(:,2), '--', 'LineWidth', 1.5);
plot(1:8760, P_GRUPO(:,3), ':', 'LineWidth', 1.5);
plot(1:8760, P_GRUPO(:,4), '-.', 'LineWidth', 1.5);
plot(1:8760, P_GRUPO(:,5), '-', 'LineWidth', 1.5, 'Color', [0 0.5 0]);
ylabel('Potència Grup [kW]');
title('Potència Grup electrògen per mode');
ylim([0 180]);
legend(compose('Mode %d', 1:5), 'Location', 'best');

configurarGrafica(8760);        %grafic consum electricitat per mode
plot(1:8760, Consum_elec);

plot(1:8760, Consum_elec(:,1), '-', 'LineWidth', 1.5);
plot(1:8760, Consum_elec(:,2), '--', 'LineWidth', 1.5);
plot(1:8760, Consum_elec(:,3), ':', 'LineWidth', 1.5);
plot(1:8760, Consum_elec(:,4), '-.', 'LineWidth', 1.5);
plot(1:8760, Consum_elec(:,5), '-', 'LineWidth', 1.5, 'Color', [0 0.5 0]);
ylabel('Consum elèctric [kWh]');
title('Consum elèctric horari per mode');
legend(compose('Mode %d', 1:5), 'Location', 'best');




litres_Mensual = zeros(12, 5);
for m = 1:12
    idxInicio = (m - 1) * 730 + 1;
    idxFin = m * 730;
    litres_Mensual(m, :) = sum(Litres(idxInicio:idxFin, :), 1);
end
%% cosum gasiol per mode
configurarGrafica(12);        %grafic consum gasoil per mode
bar(litres_Mensual, 'grouped');
ylabel('Consum de gasoil [L]');
title('Consum de gasoil horari per mode');
xlim([0.4 12.6])
ylim([15000 35000])
legend(compose('Mode %d', 1:5), 'Location', 'bestoutside');


    function E_b = E_bomba(Q_i, P_B_i, COPpoly,T_ext,T_min,T_max)
        CD=0.25;
        gcbomba = min(max(Q_i ./ P_B_i, 0), 1);               % clamp 0-1
        T_ext= max(T_min,min(T_ext,T_max));
        COPval = polyval(COPpoly, T_ext);          % vector horari
        COP = COPval .* (1 - CD .* (1 - gcbomba));  % evitar denominador 0
        COP(COP < 1e-6) = 1e-6;
        E_b = Q_i ./ COP;                        % kW elèctrics (hora a hora)
    end


end