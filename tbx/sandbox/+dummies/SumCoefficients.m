
classdef (CaseInsensitiveProperties=true) SumCoefficients < dummies.Base

    properties
        Lambda (1, 1) double = 0.1 %lambda6 in BEAR5, su-of-coefficients tightness
    end


    methods
        function out = FormFile()
            [filePath, fileTitle, fileExt] = fileparts(string(mfilename("fullpath")));
            out = fullfile(filePath, fileTitle + ".json");
        end%
    end


    methods

        function this = SumCoefficients(options)
            arguments
                options.Lambda (1, 1) double = 0.1
            end
            this.Lambda = options.Lambda;
        end%


        function dummiesYLX = generate(this, meta, longYX)
            numY = meta.NumEndogenousNames;
            numX = double(meta.HasIntercept) + meta.NumExogenousNames;
            order = meta.Order;
            lambda = this.Lambda;
            %
            [longY] = longYX{:};
            initY = longY(1:order, :);
            %
            dummiesY = diag(mean(initY, 1, "omitNaN") / lambda);
            dummiesL = kron(ones(1, order), dummiesY);
            dummiesX = zeros(numY, numX);
            dummiesLX = [dummiesL, dummiesX];
            %
            dummiesYLX = {dummiesY, dummiesLX};
        end%

    end

end

