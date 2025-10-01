
classdef (Abstract) InstantMixin < handle

    methods (Abstract)
        choleskator = getCholeskator(this)
        candidator = getCandidator(this)
    end


    methods
        function initializeSampler(this, modelS)
            %[
            arguments
                this
                modelS (1, 1) model.Structural
            end
            %
            meta = modelS.Meta;
            estimator = modelS.ReducedForm.Estimator;
            samplerR = estimator.Sampler;
            numUnits = meta.getNumUnits();
            hasCrossUnitVariationInSigma = estimator.HasCrossUnitVariationInSigma;
            identificationDrawer = estimator.IdentificationDrawer;
            choleskator = this.getCholeskator();
            candidator = this.getCandidator();
            %
            %
            function sample = structuralSampler()
                sample = samplerR();
                draw = identificationDrawer(sample);
                % u = e*D or e = u/D
                % Sigma = D'*D
                % TODO: Refactor and get rid of an if statement
                if hasCrossUnitVariationInSigma
                    Sigma = draw.Sigma;
                    Sigma = (Sigma + pagetranspose(Sigma)) / 2;
                    D = cell(1, numUnits);
                    for i = 1 : numUnits
                        P = choleskator(Sigma(:,:,i));
                        D{i} = candidator(P);
                    end
                    D = cat(3, D{:});
                else
                    Sigma = draw.Sigma(:, :, 1);
                    Sigma = (Sigma + transpose(Sigma)) / 2;
                    P = choleskator(Sigma);
                    D = candidator(P);
                    D = repmat(D, 1, 1, numUnits);
                end
                sample.IdentificationDraw = draw;
                sample.D = D;
                this.CandidateCounter = this.CandidateCounter + 1;
            end%
            %
            %
            this.Sampler = @structuralSampler;
            %]
        end%
    end

end

