function configurarGrafica(rango)

    figure;
    set(gcf, 'Position', [100, 100, 1000, 400]);  % Relació 2:1
    set(gca, 'Position', [0.07, 0.12, 0.9, 0.83]);
    grid on;
    hold on;
    ax = gca;
    ax.YAxis.Exponent = 0;

    if rango ~=0
        xlabel('Mes');
        xlim([0 rango]); 
        xticks(1:rango/12:rango);
        xticklabels({'Gener','Febrer','Març','Abril','Maig','Juny','Juliol','Agost','Setembre','Octubre','Novembre','Desembre'});
    end

end