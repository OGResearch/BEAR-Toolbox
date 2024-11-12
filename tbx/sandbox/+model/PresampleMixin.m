
classdef PresampleMixin < handle

    properties (Dependent)
        NumPresampled
    end


    methods
        function info = presample(this, numToPresample)
            arguments
                this
                numToPresample (1, 1) double {mustBeInteger, mustBeNonnegative}
            end
            this.resetPresampled(numToPresample);
            sampler = this.Sampler;
            progressMessage = sprintf("Presampling %s (%s) [%g]", class(this), this.Estimator.ShortClassName, numToPresample);
            pbar = progress.Bar(progressMessage, numToPresample);
            initSampleCount = this.SampleCounter;
            initCandidateCount = this.CandidateCounter;
            for i = 1 : numToPresample
                sample = sampler();
                this.storePresampled(i, sample);
                pbar.increment();
            end
            info = struct();
            info.SampleCount = double(this.SampleCounter - initSampleCount);
            info.CandidateCount = double(this.CandidateCounter - initCandidateCount);
            info.SuccessfulCandidateRate = numToPresample / info.CandidateCount;
            info.SuccessfulSampleRate = numToPresample / info.SampleCount;
        end%

        function out = get.NumPresampled(this)
            out = numel(this.Presampled);
        end%
    end

end

