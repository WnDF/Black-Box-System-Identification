function [r_eu, lags, maxCorrEU, conf] = residual_crosscorrelation(e, u, max_lag)
    %   Independence Test with Cross Correlation

    %   Input
    %   e:	residual sequence (vector of size N x 1)
    %   u:	system input (vector of size N x 1)
    %   max_lag:	maximum lag to test

    %   Output
    %   r_eu:	normalized cross-correlation between e and u
    %   lags:	lag values corresponding to r_eu
    %   maxCorrEU:	largest |r_eu(tau)|
    %   conf:	95% confidence bound for independence, 1.95/sqrt(N)

    N = length(e);
    if nargin < 3
        max_lag = min(200, N-1);
    end

    e0 = e - mean(e);
    u0 = u - mean(u);

    [r_eu, lags] = xcorr(e0, u0, max_lag, 'coeff');

    conf = 1.95/sqrt(N);
    maxCorrEU = max(abs(r_eu));

    figure('Position',[100 100 800 300]);
    stem(lags, r_eu, 'filled'); grid on;
    xlabel('Lag (samples)');
    ylabel('Cross-correlation (e,u)');
    title(sprintf(['Cross-correlation between residuals and input ', '(max |R_{eu}(\\tau)| = %.3f, conf = %.3f)'], maxCorrEU, conf));
    yline(conf,'r--');
    yline(-conf,'r--');
    xlim([-max_lag max_lag]);

    save_figure('residual_crosscorrelation_input.png');
end
