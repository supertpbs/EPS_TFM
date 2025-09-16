function [Cost_hor,Emissions_hor] = SIMULACIO_ECONOMICA(Consum_elec,Litres)
%%DADES GASOIL
D_Preu_gasoil= 1.229;         %€/litre gasoil
D_Emi_gasoil= 2.7047/1000;    %tonelades CO2/litre gasoil
D_Emi_electr= 0.43;           %tonelades CO2eq/MWh electr. xarxa

%% DADES ELEC
[p_elec_compra,precio_medio_compra] = IMPORTAR_OMIE('precios_pibcic_2022');
[p_elec_venta,precio_medio_venta] = IMPORTAR_PDBC('marginalpdbc_2022');


configurarGrafica(8760);
plot(1:8760, p_elec_compra(2,:), 'b-', 'DisplayName', 'Preu mínim compra');
plot(1:8760, p_elec_compra(1,:), 'b--', 'DisplayName', 'Preu máxim compra');
plot(1:8760, p_elec_compra(3,:), 'b:', 'DisplayName', 'Preu mitjà compra');
plot(1:8760, p_elec_venta, 'r-', 'LineWidth', 1.5, 'DisplayName', 'Preu venta');
ylabel('Preu [€/MWh]');
title('Preus de compra i venta OMIE Espanya 2022');
legend('Location', 'best');

%%
Cost_hor = D_Preu_gasoil * Litres + (p_elec_compra(3, :)' .* max(0, Consum_elec)./1000 + p_elec_venta' .* min(0, Consum_elec)./1000);
Emissions_hor = Litres * D_Emi_gasoil + (Consum_elec ./ 1000) * D_Emi_electr; 

[Cost_optim,Emi_optim] = OPTIMITZACIO_SISTEMA(Cost_hor,Emissions_hor);

FLUX_CAIXA=sum(Cost_hor(:,1)-Cost_optim);
disp('FLUX_CAIXA:')
disp(FLUX_CAIXA)

end
