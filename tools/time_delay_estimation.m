function [nk, Td, r, lags] = time_delay_estimation(u, y, fs)
    %   Estimate Causal Input Output Delay via Cross Correlation

    %   Input
    %   u:	system input (vector of size N x 1)
    %   y:	system output (vector of size N x 1)
    %   fs:	sampling frequency (scalar, Hz)

    %   Output
    %   nk:	estimated causal delay
    %   Td:	estimated causal delay
    %   r:	normalized cross-correlation between y and u
    %   lags:	lag values corresponding to r

    u0 = u - mean(u);
    y0 = y - mean(y);

    [r, lags] = xcorr(y0, u0, 'coeff');

    nonneg = lags >= 0;
    r_pos = r(nonneg);
    lags_pos = lags(nonneg);

    [~, idxMax] = max(r_pos);
    nk = lags_pos(idxMax);
    Td = nk / fs;
end
