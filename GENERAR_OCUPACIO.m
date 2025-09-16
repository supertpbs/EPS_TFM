function Cap_real = GENERAR_OCUPACIO(Cap_hostes_max, Cap_variacio_mensual,coef_ruido)
    % Calcular la variación semanal normalizada
    Cap_variacio_setmanal = [0.9, 1.1, 1.0, 1.0, 1.0, 1.1, 1.1]; % Vector de variación semanal

    Cap_variacio_setmanal = (Cap_variacio_setmanal / sum(Cap_variacio_setmanal)) * 7;  
    Cap_variacio_setmanal_anual = repmat(Cap_variacio_setmanal, 1, 53); % Expandir para 52 semanas
    
    % Calcular la variación mensual suavizada
    dies_mesos = linspace(1, 365, 12);
    idx_no_zero = Cap_variacio_mensual ~= 0;
    dies_mesos_no_zero = dies_mesos(idx_no_zero);
    valors_no_zero = Cap_variacio_mensual(idx_no_zero);
    Cap_variacio_mensual_suau = interp1(dies_mesos_no_zero, valors_no_zero, 1:365, 'pchip', 0);
    
    % Calcular la capacidad real
    Cap_real = Cap_hostes_max * Cap_variacio_mensual_suau(1:365) .* Cap_variacio_setmanal_anual(1:365);
    
    ruido = coef_ruido * (2 * rand(size(Cap_real)) - 1);  % rang [-1, +1]
    Cap_real = Cap_real .* (1 + ruido);  % afegim soroll multiplicatiu

    % Assegurar que la capacitat no sigui negativa
    Cap_real = max(Cap_real, 0);

    figure;
    set(gcf, 'Position', [100, 100, 1000, 400]);  % Relació 2:1 (amplada:alçada)
    tight_pos = [0.07, 0.12, 0.9, 0.83];
    set(gca, 'Position', tight_pos);

    plot(1:365, Cap_real, 'LineWidth', 2);
    ylabel('Ocupació (pax)');
    title('Ocupació diària');
    grid on;
    xlim([1 365]); % Limitar l'eix X a 365 dies
    xticks(0:31:365); % Marcar els mesos cada 30 dies
    xticklabels({'Gener', 'Febrer', 'Març', 'Abril', 'Maig', 'Juny', 'Juliol', 'Agost', 'Setembre', 'Octubre', 'Novembre', 'Desembre'});
    xlabel('Mesos');

end