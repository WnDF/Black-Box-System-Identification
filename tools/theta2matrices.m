function [Abar, Bbar, C, D, Kbar, x0] = theta2matrices(theta)
    %   Unpack a PEM Parameter Vector into ARMAX State Space Form

    %   Input
    %   theta:	parameter vector (vector of size 12 x 1)

    %   Output
    %   Abar:	state matrix A (matrix of size 3 x 3)
    %   Bbar:	input matrix B (matrix of size 3 x 1)
    %   C:	output matrix C (matrix of size 1 x 3)
    %   D:	feedthrough matrix D (scalar)
    %   Kbar:	innovations (Kalman) gain (matrix of size 3 x 1)
    %   x0:	initial state (vector of size 3 x 1)

    % A
    Abar = [0 1 0;
            0 0 1;
            theta(1) theta(2) theta(3)];
    % B
    Bbar = [theta(4); theta(5); theta(6)];

    % Kalman Gain
    Kbar = [theta(7); theta(8); theta(9)];

    % Output
    C = [1 0 0];
    D = 0;

    % Initials
    x0 = theta(10:12);
end
