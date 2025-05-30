function obj = updateData(obj, data)
    % Update the metadata with user-provided data
    % obj: The object containing the metadata
    % data: A struct containing the new data to update

    if isempty(data)
        return; % No data to update
    end

    fieldNames = fieldnames(data);
    for i = 1:numel(fieldNames)
        fieldName = fieldNames{i};
        if isfield(obj, fieldName)
            obj.(fieldName).value = data.(fieldName);
        else
            warning('Field "%s" does not exist in the metadata object.', fieldName);
        end
    end
end