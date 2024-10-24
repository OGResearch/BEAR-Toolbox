
classdef PresampleMixin < handle

    methods

        function info = presample(this, numToPresample)
            arguments
                this
                numToPresample (1, 1) double {mustBeInteger, mustBeNonnegative}
            end
            this.Presampled = cell(1, numToPresample)
            sampler = this.getSampler();
            info = struct();
            info.NumCandidates = 0;
            progressMessage = sprintf("Presampling %s [%g]", class(this), numToPresample);
            pbar = progress.Bar(progressMessage, numToPresample);
            for i = 1 : numToPresample
                sample = sampler();
                numCandidates = 1;
                if isfield(sample, "NumCandidates")
                    numCandidates = sample.NumCandidates;
                end
                info.NumCandidates = info.NumCandidates + numCandidates;
                this.Presampled{i} = sample;
                pbar.increment();
            end
            info.AcceptanceRatio = this.NumPresampled / info.NumCandidates;
        end%

    end

end

