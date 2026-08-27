function rmse = RMSE(y, yhat)
    %   Root Mean Squared Error

    %   Input
    %   y:	measured system output (matrix of size N x l)
    %   yhat:	simulated system output (matrix of size N x l)

    %   Output
    %   rmse:	Root Mean Squared Error (scalar)

    rmse = sqrt(mean((y - yhat).^2));
end
