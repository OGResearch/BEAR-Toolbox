
function X = addInterceptWhenNeeded(X, hasIntercept)

    if ~hasIntercept
        return
    end

    X = [ones(size(X, 1), 1), X];

end%
