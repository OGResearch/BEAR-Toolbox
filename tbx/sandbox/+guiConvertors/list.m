function x = list(input)
    
    % Convert input to a list of strings
    if ischar(input) || isstring(input)
        x = strsplit(input, ',');
        x = strtrim(x);  % Remove leading/trailing whitespace
        return
    end
    error('Resolve an invalid type.');
end