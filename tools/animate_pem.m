function animate_pem(y, yhat, vaf, rmse, algo)
    %   Animated Truth vs Estimate Sweep on Validation Data

    %   Input
    %   y:	measured system output (vector of size N x 1)
    %   yhat:	simulated system output (vector of size N x 1)
    %   vaf:	Variance Accounted For to reveal at the end of the sweep (scalar)
    %   rmse:	Root Mean Squared Error to reveal at the end of the sweep (scalar)
    %   algo:	algorithm name to display in the title (string)

    %   Output
    %   none

    N = length(y);
    nFrames = min(N, 150);
    step = max(1, round(N/nFrames));
    frameIdx = unique([1:step:N, N]);

    fig = figure('Position', [100 100 800 400]);
    hTruth = plot(nan, nan, 'LineWidth', 1.2); hold on;
    hEst   = plot(nan, nan, 'LineWidth', 1.2);
    legend('truth','estimate','Orientation','horizontal');
    title({algo, 'Validation'});
    xlabel('k')
    ylabel('$y, \hat{y}$','Interpreter','latex');
    grid on;
    xlim([1 N]);
    pad = 0.05 * (max(y) - min(y));
    ylim([min(y)-pad, max(y)+pad]);

    repoRoot = fileparts(fileparts(mfilename('fullpath')));
    assetsDir = fullfile(repoRoot, 'assets');
    if ~exist(assetsDir, 'dir')
        mkdir(assetsDir);
    end
    gifPath = fullfile(assetsDir, [strrep(lower(algo), '-', ''), '_validation_fit.gif']);

    for i = 1:length(frameIdx)
        k = frameIdx(i);
        hTruth.XData = 1:k; hTruth.YData = y(1:k);
        hEst.XData   = 1:k; hEst.YData   = yhat(1:k);

        if i == length(frameIdx)
            title({algo, sprintf('Validation | VAF = %.2f%%, RMSE = %.2f', vaf, rmse)});
        end
        drawnow;

        frame = getframe(fig);
        [imind, cmap] = rgb2ind(frame2im(frame), 256);

        delay = 0.04;
        if i == length(frameIdx)
            delay = 2.0; % hold on the finished trace before looping
        end

        if i == 1
            imwrite(imind, cmap, gifPath, 'gif', 'LoopCount', Inf, 'DelayTime', delay);
        else
            imwrite(imind, cmap, gifPath, 'gif', 'WriteMode', 'append', 'DelayTime', delay);
        end
    end

    close(fig);
end
