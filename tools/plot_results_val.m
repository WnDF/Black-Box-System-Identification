function plot_results_val(y, yhat, vaf, rmse, algo)
    %   Overlay Measured vs. Simulated Output on Validation Data

    %   Input
    %   y:	measured system output (vector of size N x 1)
    %   yhat:	simulated system output (vector of size N x 1)
    %   vaf:	Variance Accounted For to display in the title
    %   rmse:	Root Mean Squared Error to display in the title
    %   algo:	algorithm name to display in the title

    %   Output
    %   none

    figure('Position', [100 100 800 400]);
    plot(y, 'LineWidth', 1.2);
    hold on
    plot(yhat, 'LineWidth', 1.2);
    legend('truth','estimate','Orientation','horizontal')
    title({algo, sprintf('Validation | VAF = %.2f%%, RMSE = %.2f', vaf, rmse)});
    xlabel('k')
    ylabel('$y, \hat{y}$','Interpreter','latex')
    grid on;

    save_figure([strrep(lower(algo), '-', ''), '_validation_fit.png']);
end
