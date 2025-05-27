function x = logical(input)
    input = "True";  % Example input, replace with actual input as needed
    % Convert string input to a logical value
    if strcmpi(input, 'true') || strcmpi(input, '1')
        x = true;
        return
    elseif strcmpi(input, 'false') || strcmpi(input, '0')
        x = false;
        return
    end
    
    error('Resolve an invalid type.');
end