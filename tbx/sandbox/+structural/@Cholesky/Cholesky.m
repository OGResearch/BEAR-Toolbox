
classdef Cholesky < structural.AbstractIdentifier

    properties
    end

    methods
        function outSampler = initializeSampler(this, structuralMeta, reducedForm)

            function zeta = sampler(reducedFormSystem)
                [A, C, Sigma] = reducedFormSystem{:};
                D = cholcov(Sigma);
                zeta = D(:);
            end%

            outSampler = @sampler;
        end%
    end

end
