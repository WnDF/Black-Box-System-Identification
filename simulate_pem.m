function [yhat, xhat, ehat] = simulate_pem(A, B, C, D, K, x0, u, y)
    %   One Step Ahead Prediction with an ARMAX Model

    %   Input
    %   A:	state matrix (matrix of size n x n)
    %   B:	input matrix (matrix of size n x 1)
    %   C:	output matrix (matrix of size 1 x n)
    %   D:	feedthrough matrix
    %   K:	innovations (Kalman) gain (matrix of size n x 1)
    %   x0:	initial state (vector of size n x 1)
    %   u:	system input (vector of size N x 1)
    %   y:	measured system output, used to form e_k = y_k - C*x_k (vector of size N x 1)

    %   Output
    %   yhat:	one-step-ahead output prediction (vector of size N x 1)
    %   xhat:	predicted state trajectory (matrix of size N x n)
    %   ehat:	prediction error / innovation sequence (vector of size N x 1)

    N = length(u);
    n = size(A,1);

    xhat = zeros(N,n);
    yhat = zeros(N,1);
    ehat = zeros(N,1);

    % Initial condition
    xhat(1,:) = x0.';

    for k = 1:N

        % Output prediction
        yhat(k) = C * xhat(k,:).';

        % Prediction Error
        ehat(k) = y(k) - yhat(k);

        % State update
        if k < N
            xhat(k+1,:) = (A*xhat(k,:).' + B*u(k) + K*ehat(k)).';
        end
    end
end
