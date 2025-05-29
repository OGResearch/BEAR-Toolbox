function x = number(input)
    x = double(input);
    if isnumeric(x) && isscalar(x)
        return
    end

    error('Resolve an invalid type.');
end