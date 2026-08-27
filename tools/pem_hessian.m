function H = pem_hessian(psi)
    %   Gauss-Newton Approximate Hessian of the Prediction-Error Cost

    %   Input
    %   psi:	derivative of estimation error wrt theta (matrix of size l*N x p)

    %   Output
    %   H:	Hessian matrix (matrix of size p x p)

    H = 2/length(psi(:,1)) * (psi' * psi);
end
