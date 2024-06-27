
% identification.Base  Base class for identification schemes

classdef Base < handle

    properties
        Settings
    end

    properties
        Preallocator
        Sampler
        SamplerCounter (1,1) uint32 = 0
    end

    properties (Dependent)
        Gamma
        VarVec
    end

    methods (Abstract)
        varargout = initializeSampler(this, varargin)
    end

    methods
        function varargout = initialize(this, reducedForm, YLX)
            arguments
                this
                reducedForm (1, 1) reducedForm.Model
                YLX (1, 3) cell
            end
            this.initializeSampler(reducedForm);
        end%

        function flag = beenInitialized(this)
            flag = ~isempty(this.Sampler) && ~isempty(this.Preallocator);
        end%

        function initializePreallocator(this, YLX)
            [Y, L, X] = YLX{:};
            numY = size(Y, 2);
            numD = numY * numY;
            %
            if this.Settings.TimeVariant
                numPeriods = numT;
            else
                numPeriods = 1;
            end
            %
            function sample = preallocator(numDraws)
                sample = { ...
                    nan(numPeriods, numDraws, numD) ...
                };
            end%
            %
            this.Preallocator = @preallocator;
        end%

        function finalizeFromMetaAndReducedForm(this, strMeta, redModel)
            numY = redModel.Meta.NumEndogenousColumns;
            this.Settings.TimeVariant = redModel.Estimator.Settings.TimeVariant;
            if isscalar(this.Settings.StdVec)
                this.Settings.StdVec = repmat(this.Settings.StdVec, numY, 1);
            end
        end%
    end

    methods
        function Gamma = get.Gamma(this)
            Gamma = diag(this.VarVec);
        end%

        function VarVec = get.VarVec(this)
            VarVec = this.Settings.StdVec .^ 2;
        end%
    end

end

