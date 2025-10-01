
classdef SignRestrictions

    methods (Static)
        function verifiableTests = toVerifiableTestStrings(tbl)
            arguments
                tbl (:, :) table
            end
            %
            % identifier.SignRestrictions.checkTable(tbl, meta);
            % horizon = meta.IdentificationHorizon;
            %
            endogenousNames = string(tbl.Properties.RowNames);
            shockNames = string(tbl.Properties.VariableNames);
            numEndogenousNames = numel(endogenousNames);
            numShockNames = numel(shockNames);
            %
            data = identifier.SignRestrictions.homogenizeTableData(tbl);
            verifiableTests = string.empty(0, 1);
            for i = 1 : numEndogenousNames
                for j = 1 : numShockNames
                    if data(i, j) == ""
                        continue
                    end
                    expression = strip(extractBefore(data(i, j), "["));
                    expression = erase(expression, " ");
                    periods = extractBetween(data(i, j), "[", "]", boundaries="inclusive");
                    periods = eval(periods);
                    if isempty(periods) || ~isnumeric(periods) || any(periods < 0) || any(periods ~= round(periods))
                        error("This sign restriction table entry has invalid periods: %s", data(i, j));
                    end
                    periods = sort(unique(reshape(periods, 1, [])));
                    numPeriods = numel(periods);
                    %
                    periods = string(periods);
                    if numPeriods > 1
                        periods = "[" + join(periods, ",") + "]";
                    end
                    test = sprintf( ...
                        "$SHKRESP(%s,'%s','%s')%s", ...
                        periods, ...
                        endogenousNames(i), ...
                        shockNames(j), ...
                        expression ...
                    );
                    if numPeriods > 1
                        test = "all(" + test + ")";
                    end
                    verifiableTests(end+1, 1) = test;
                end
            end
        end%

        % function expressions = toVerifiables(tbl)
        %     %[
        %     identifier.SignRestrictions.checkConsistency(tbl);
        %     %
        %     endogenousNames = string(tbl.Properties.RowNames);
        %     shockNames = string(tbl.Properties.VariableNames);
        %     numEndogenousNames = numel(endogenousNames);
        %     numShockNames = numel(shockNames);
        %     %
        %     data = reshape(tbl{:, :}, numEndogenousNames, [], numShockNames);
        %     ind = find(~isnan(data));
        %     [row, column, page] = ind2sub(size(data), ind);
        %     %
        %     numExpressions = numel(row);
        %     signs = repmat("", size(row));
        %     signs(data(ind) == 1) = ">";
        %     signs(data(ind) == -1) = "<";
        %     expressions = cell(1, numExpressions);
        %     for i = 1 : numExpressions
        %         expressions{i} = sprintf( ...
        %             "$SHKRESP(%g, '%s', '%s') %s 0", ...
        %             column(i), ...
        %             endogenousNames(row(i)), ...
        %             shockNames(page(i)), ...
        %             signs(i) ...
        %         );
        %     end
        %     expressions = cat(1, expressions{:});
        %     %]
        % end%

        function checkTable(tbl, meta)
            arguments
                tbl (:, :) table
                meta (1, 1) model.Meta
            end
            %
            identifier.checkEndogenousAndShocksInTable(tbl, meta);
            data = tbl{:, :};
            if ~isstring(data) && ~ischar(data)
                error("Sign restriction table entries must be strings or characters.");
            end
            data = identifier.SignRestrictions.homogenizeTableData(tbl);
            data(data == "") = [];
            if isempty(data)
                return
            end
            inxValid = startsWith(data, "<") | startsWith(data, ">");
            if ~all(inxValid(:))
                error("Non-empty sign restriction table entries must start with '<' or '>'.");
            end
            inxValid = (contains(data, "[") & contains(data, "]"));
            if ~all(inxValid(:))
                error("Non-empty sign restriction table entries must contain periods enclosed between '[' and ']'.");
            end
        end%

        function data = homogenizeTableData(tbl)
            arguments
                tbl (:, :) table
            end
            %
            data = tbl{:, :};
            data = strip(string(data));
            data(ismissing(data)) = "";
        end%

    end

end

