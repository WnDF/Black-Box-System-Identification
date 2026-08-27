function [A, B, C, D, x0] = pomoesp(u, y, s)
    %   POMOESP Subspace Identification

    %   Input
    %   u:	system input (vector of size N x 1)
    %   y:	system output (vector of size N x 1)
    %   s:	block size, s > expected system order (scalar)

    %   Output
    %   A:	system matrix A (matrix of size n x n)
    %   B:	system matrix B (matrix of size n x 1)
    %   C:	system matrix C (matrix of size 1 x n)
    %   D:	system matrix D (scalar)
    %   x0:	initial state (vector of size n x 1)

    N = length(u);

    %% I. Hankel matrices
    K = N - 2*s + 1;

    U_hankel = zeros(2*s, K);
    Y_hankel = zeros(2*s, K);

    for i = 1:2*s
        U_hankel(i,:) = u(i:i+K-1);
        Y_hankel(i,:) = y(i:i+K-1);
    end

    Up = U_hankel(1:s,:);
    Uf = U_hankel(s+1:end,:);
    Yp = Y_hankel(1:s,:);
    Yf = Y_hankel(s+1:end,:);

    Z = [Up; Yp];

    %% II. LQ factorization with QR
    W = [Uf; Z; Yf];
    R = qr(W.', "econ");     % economy QR, no explicit Q
    L = R.';

    nUf = size(Uf,1);
    nZ  = size(Z,1);

    L_32 = L(nUf+nZ+1:end , nUf+1:nUf+nZ);

    %% III. n, A and C
    [U,S,~] = svd(L_32,'econ');
    svals = diag(S);

    figure('Position', [100 100 800 250]);
    semilogy(svals,'o-'); grid on;
    xlabel('Index i'); ylabel('\sigma_i');
    title('Singular values as Semilog Plot');
    save_figure('singular_values_semilog.png');

    n = input('Choose model order n = ');

    Os = U(:,1:n);

    C = Os(1,:);
    A = Os(1:end-1,:) \ Os(2:end,:);

    %% IV. x0, B, D
    Phi = zeros(N, n+n+1);

    for k = 1:N
        % vals for x0
        Phi(k,1:n) = C * A^(k-1);

        % vals for vec(B)
        for i = 1:k-1
            Phi(k,n+1:2*n) = Phi(k,n+1:2*n) + ...
                (C * A^(k-1-i)) * u(i);
        end

        % vals for vec(D)
        Phi(k,2*n+1) = u(k);
    end

    theta = Phi \ y(:);

    x0 = theta(1:n);
    B  = theta(n+1:2*n);
    D  = theta(2*n+1);
end
