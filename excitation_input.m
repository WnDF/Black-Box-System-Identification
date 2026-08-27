function [u, t] = excitation_input(T_exp, fs, x_max, n_steps)
    %   Generate Persistently Exciting Input

    %   Input
    %   T_exp:	experiment duration
    %   fs:	sampling frequency
    %   x_max:	maximum staircase level
    %   n_steps:	number of staircase segments

    %   Output
    %   u:	input signal (vector of size N x 1)
    %   t:	time vector (vector of size N x 1)

    N = T_exp * fs;
    t = (0:N-1)'/fs;

    step_length = floor(N / n_steps);
    levels = x_max * rand(n_steps, 1);

    u = zeros(N, 1);
    for k = 1:n_steps
        idx = (k-1)*step_length + 1 : min(k*step_length, N);
        u(idx) = levels(k);
    end
end
