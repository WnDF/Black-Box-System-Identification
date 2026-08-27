function [y_clean, idx_spike] = spike_removal(y, t, k_mad)
    %   Detect and Interpolate Spikes via Median Absolute Deviation (MAD)

    %   Input
    %   y:	system output (vector of size N x 1)
    %   t:	time vector (vector of size N x 1)
    %   k_mad:	spike detection threshold multiplier

    %   Output
    %   y_clean:	output with spikes interpolated over (vector of size N x 1)
    %   idx_spike:	logical index of detected spikes (vector of size N x 1)

    if nargin < 3
        k_mad = 6;
    end

    y_med = median(y);
    MAD = median(abs(y - y_med));
    threshold = k_mad * 1.4826 * MAD;
    idx_spike = abs(y - y_med) > threshold;

    y_clean = y;
    y_clean(idx_spike) = interp1(t(~idx_spike), y(~idx_spike), t(idx_spike), 'linear', 'extrap');
end
