function [Abar, Bbar, C, D, Kbar, x0, J, H] = pem(theta, y, u, lambda, maxiter)
    %   Prediction Error Method for ARMAX Model

    %   Input
    %   theta:	initial parameter vector (vector of size 12 x 1, see theta2matrices.m)
    %   y:	measured system output (vector of size N x 1)
    %   u:	system input (vector of size N x 1)
    %   lambda:	Levenberg-Marquardt damping factor
    %   maxiter:	maximum number of iterations

    %   Output
    %   Abar:	state matrix A (matrix of size 3 x 3)
    %   Bbar:	input matrix B (matrix of size 3 x 1)
    %   C:	output matrix C (matrix of size 1 x 3)
    %   D:	feedthrough matrix D
    %   Kbar:	innovations (Kalman) gain (matrix of size 3 x 1)
    %   x0:	initial state (vector of size 3 x 1)
    %   J:	Gauss-Newton gradient at convergence (vector of size 12 x 1)
    %   H:	Gauss-Newton approximate Hessian at convergence (matrix of size 12 x 12)

    n = 3;
    p = length(theta);
    N = length(y);

    converged = false;
    iter = 1;

    while ~converged && iter <= maxiter

        % Unpack parameters
        [Abar, Bbar, C, D, Kbar, x0] = theta2matrices(theta);

        % Initialize
        x = x0;
        S = zeros(n,p);

        % Sensitivities for x0
        S(:,10:12) = eye(n);

        yhat = zeros(N,1);
        psi  = zeros(N,p);

        for k = 1:N

            % Output
            yhat(k) = C*x;

            % dyhat/dtheta = C * S
            psi(k,:) = -(C*S);

            % Residual
            e = y(k) - yhat(k);
            uk = u(k);

            S_next = zeros(n,p);

            for j = 1:p

                dA = zeros(n,n);
                dB = zeros(n,1);
                dK = zeros(n,1);

                % A params.
                if j <= 3
                    dA(3,j) = 1;
                end

                % B param.
                if j >= 4 && j <= 6
                    dB(j-3) = 1;
                end

                % K params.
                if j >= 7 && j <= 9
                    dK(j-6) = 1;
                end

                % de/dtheta = -C * S(:,j)
                de = -(C*S(:,j));

                % Sensitivity update (ARMAX)
                S_next(:,j) = ...
                    Abar*S(:,j) + ...
                    dA*x + ...
                    dB*uk + ...
                    dK*e + ...
                    Kbar*de;
            end

            % State update with K
            x = Abar*x + Bbar*uk + Kbar*e;

            S = S_next;
        end

        % Prediction error
        E = y - yhat;

        % Gradient & Hessian
        J = pem_jacobian(psi,E);
        H = pem_hessian(psi);

        % Levenberg-Marquardt update
        dtheta = -(H + lambda*eye(p)) \ J;
        theta_new = theta + dtheta;

        % Convergence check
        if norm(theta_new - theta) < 1e-3
            converged = true;
        end

        theta = theta_new;
        iter = iter + 1;
    end

    [Abar,Bbar,C,D,Kbar,x0] = theta2matrices(theta);
end
