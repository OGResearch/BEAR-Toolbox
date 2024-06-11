
% identification.Base  Base class for identification schemes

classdef Base < handle

    properties
        Settings
        Sampler = []
        SamplerCounter (1,1) uint32 = 0
    end

    methods (Abstract)
        varargout = initializeSampler(this, varargin)
    end

    methods
        function varargout = initialize(this, meta, reducedForm, dataTable, periods)
            arguments
                this
                meta (1, 1) structural.Meta
                reducedForm (1, 1) reducedForm.Model
                dataTable (:, :) timetable
                periods (1, :) datetime
            end

            if ~reducedForm.Estimator.beenInitialized()
                YLX = reducedForm.Estimator.initialize(reducedForm.Meta, dataTable, periods);
            else
                YLX = reducedForm.Meta.getDataYLX(dataTable, periods);
            end
            this.initializeSampler(meta, reducedForm);
        end%

        function flag = beenInitialized(this)
            flag = ~isempty(this.Sampler);
        end%
    end

end

