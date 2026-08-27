function rankH = persistency_of_excitation(u, s_max)
    %   Hankel-Matrix Rank Test for Persistency of Excitation

    %   Input
    %   u:	system input (vector of size N x 1)
    %   s_max:	maximum block size to test (scalar)

    %   Output
    %   rankH:	rank(U_s) for s = 1..s_max (vector of size s_max x 1)

    N = length(u);
    c = u(1:(N - s_max + 1));
    r = u((N - s_max + 1):N);
    H = hankel(c, r);

    rankH = zeros(s_max, 1);
    for s = 1:s_max
        rankH(s) = rank(H(:, 1:s));
    end
end
