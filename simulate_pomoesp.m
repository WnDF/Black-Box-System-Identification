function [y, x] = simulate_pomoesp(A, B, C, D, x0, u)
    %   Open Loop Simulation of a Deterministic State-Space Model

    %   Input
    %   A:	system matrix (matrix of size n x n)
    %   B:	system matrix (matrix of size n x m)
    %   C:	system matrix (matrix of size l x n)
    %   D:	system matrix (matrix of size l x m)
    %   x0:	initial state (vector of size n x one)
    %   u:	system input (matrix of size N x m)

    %   Output
    %   y:	system output (matrix of size N x l)
    %   x:	state of system (vector of size N x n)

    % Dimensions
    N = size(u,1);     % number of time steps
    n = size(A,1);     % number of states
    l = size(C,1);     % number of outputs

    % Preallocate state and output matrices
    x = zeros(N, n);   % state: N x n
    y = zeros(N, l);   % output: N x l

    % Initial condition
    x(1,:) = x0.';      % store as row vector

    % Simulation loop
    for k = 1:N
        % Output equation
        y(k,:) = (C*x(k,:).' + D*u(k,:).').';

        % State update (except at final time step)
        if k < N
            x(k+1,:) = (A*x(k,:).' + B*u(k,:).').';
        end
    end
end
