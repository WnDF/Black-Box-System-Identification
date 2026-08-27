function J = pem_jacobian(psi, E)
    %   Gauss Newton Gradient of the Prediction Error Cost

    %   Input
    %   psi:	derivative of estimation error wrt theta (matrix of size l*N x p)
    %   E:	estimation error vector (vector of size l*N x one)

    %   Output
    %   J:	Jacobian vector (vector of size p x one)

    J = 2/length(psi(:,1)) * psi' * E;
end
