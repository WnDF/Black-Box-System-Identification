function [u_shifted, y_shifted, t_shifted] = time_shift(u, y, nk, fs)
    %   Align Input/Output Data for a Known Causal Delay

    %   Input
    %   u:	system input (vector of size N x 1)
    %   y:	system output (vector of size N x 1)
    %   nk:	causal delay to compensate
    %   fs:	sampling frequency

    %   Output
    %   u_shifted:	truncated input, synchronized with y_shifted
    %   y_shifted:	shifted output, synchronized with u_shifted
    %   t_shifted:	time vector for the shifted signals

    u_shifted = u(1:end-nk);
    y_shifted = y(1+nk:end);
    t_shifted = (0:length(u_shifted)-1)'/fs;
end
