
classdef ReducedForm < base.ReducedForm

    properties
        Dummies (1, :) cell = cell.empty(1, 0)
    end

    properties (Dependent)
        HasDummies (1, 1) logical
        NumDummies (1, 1) double
    end


    methods

        function this = ReducedForm(options)

            arguments
                options.meta (1, 1) base.Meta
                options.dataHolder (:, :) base.DataHolder
                options.estimator (1, 1) estimator.Base
                options.stabilityThreshold (1, 1) double = NaN
                options.dummies (1, :) cell = cell.empty(1, 0)
            end

            this@base.ReducedForm( ...
                'meta', options.meta, ...
                'dataHolder', options.dataHolder, ...
                'estimator', options.estimator, ...
                'stabilityThreshold', options.stabilityThreshold);

            this.Dummies = options.dummies;

        end%


        function [longYX, dummiesYLX, indivDummiesYLX] = initialize(this)
            longYX = this.getLongYX();
            [dummiesYLX, indivDummiesYLX] = this.generateDummiesYLX(longYX);
            this.Estimator.initialize(this.Meta, longYX, dummiesYLX);
        end%


        function [allDummiesYLX, indivDummiesYLX] = generateDummiesYLX(this, longYLX)
            indivDummiesYLX = cell(1, this.NumDummies);
            for i = 1 : this.NumDummies
                indivDummiesYLX{i} = this.Dummies{i}.generate(this.Meta, longYLX);
            end
            allDummiesYLX = this.Meta.createEmptyYLX();
            allDummiesYLX = system.mergeDataCells(allDummiesYLX, indivDummiesYLX{:});
        end%


    end

    methods

        function flag = get.HasDummies(this)
            flag = ~isempty(this.Dummies);
        end%

        function num = get.NumDummies(this)
            num = numel(this.Dummies);
        end%

    end

end
