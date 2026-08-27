function [r, lags, maxCorr, conf] = residual_autocorrelation(e, max_lag)
    %   Whiteness Test with Autocorrelation

    %   Input
    %   e:	residual sequence (vector of size N x 1)
    %   max_lag:	maximum lag to test

    %   Output
    %   r:	normalized autocorrelation of e
    %   lags:	lag values corresponding to r
    %   maxCorr:	largest |r(tau)| for tau ~= 0
    %   conf:	95% confidence bound for white noise, 1.95/sqrt(N)

    N = length(e);
    if nargin < 2
        max_lag = min(200, N-1);
    end

    [r, lags] = xcorr(e - mean(e), max_lag, 'coeff');

    conf = 1.95/sqrt(N);

    r_nz = r(lags ~= 0);
    maxCorr = max(abs(r_nz));

    figure('Position', [100 100 800 300]);
    stem(lags, r, 'filled'); grid on;
    xlabel('Lag (samples)');
    ylabel('Residual autocorrelation');
    title(sprintf(['Residual autocorrelation ', '(max |R_e(\\tau)| for \\tau \\neq 0 = %.3f, conf = %.3f)'], maxCorr, conf));
    yline(conf,'r--');
    yline(-conf,'r--');
    xlim([-max_lag max_lag]);

    save_figure('residual_autocorrelation.png');
end
