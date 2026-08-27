function vaf = VAF(y, yhat)
    %   Variance Accounted For

    %   Input
    %   y:	measured system output (matrix of size N x l)
    %   yhat:	simulated system output (matrix of size N x l)

    %   Output
    %   vaf:	Variance Accounted For

    vaf = max(0, 1 - (mean((y - yhat).^2))/(mean(y.^2))) * 100;
end
