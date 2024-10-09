function [Y, X] = lj_get_XY_format(data_endo,const,lags)

    % first compute N, the number of units, as the dimension of the data_endo matrix
    N=size(data_endo,3);

    % then compute n, the number of endogenous variables in the model; it is simply the number of columns in the matrix 'data_endo'
    n=size(data_endo,2);

    Y = [];
    X = [];
    % Yi = [];
    % Xi = [];
    for ii = 1:N
      % use the lagx function on the data matrix
      temp=bear.lagx(data_endo(:,:,ii),lags);
      % set Yi as the first n columns of the result
      % Yi(:,:,ii)=temp(:,1:n);
      Y = [Y temp(:,1:n)];

      % to build Xi, take off the n initial columns of temp
      % Xi(:,:,ii)=[temp(:,n+1:end)];
      X = [X temp(:,n+1:end)];
    end

end