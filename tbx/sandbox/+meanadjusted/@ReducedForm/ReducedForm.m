
classdef ReducedForm < model.ReducedForm

    methods

        function someYXZ = getSomeYXZ(this, span)
            someYXZ = this.DataHolder.getYXZ(span=span);
            meta = this.Meta;
            someYXZ{2} = meta.getX(span);
        end%

        function [forecaster, tabulator] = prepareForecaster(this, shortFcastSpan, options)
            arguments
                this
                shortFcastSpan (1, :) datetime
                options.StochasticResiduals
                options.IncludeInitial
            end
            %
            variantDim = 3;
            meta = this.Meta;
            fcastStart = shortFcastSpan(1);
            fcastEnd = shortFcastSpan(end);
            this.checkForecastSpan(fcastStart, fcastEnd);
            forecastStartIndex = datex.diff(fcastStart, meta.ShortStart) + 1;
            forecastHorizon = numel(shortFcastSpan);
            longFcastSpan = datex.longSpanFromShortSpan(shortFcastSpan, meta.Order);
            longYXZ = this.getSomeYXZ(longFcastSpan);
            outNames = [meta.EndogenousNames, meta.ResidualNames];
            %
            function [shortY, shortU, initY, draw] = forecaster__(sample)
                [shortY, shortU, initY, draw] = this.forecast4S( ...
                    sample, longYXZ, forecastStartIndex, forecastHorizon ...
                    , stochasticResiduals=options.StochasticResiduals ...
                    , order=meta.Order ...
                );
            end%
            %
            function outTable = tabulator__(shortY, shortU, initY)
                shortY = cat(variantDim, shortY{:});
                shortU = cat(variantDim, shortU{:});
                if options.IncludeInitial
                    outSpan = longFcastSpan;
                    initY = cat(variantDim, initY{:});
                    initU = nan(size(initY));
                    outData = [[initY, initU]; [shortY, shortU]];
                else
                    outSpan = shortFcastSpan;
                    outData = [shortY, shortU];
                end
                %
                outTable = tablex.fromNumericArray(outData, outNames, outSpan, variantDim=variantDim);
            end%
            %
            forecaster = @forecaster__;
            tabulator = @tabulator__;
        end%


        function varargout = forecast(this, fcastSpan, options)
            arguments
                this
                fcastSpan (1, :) datetime
                options.StochasticResiduals (1, 1) logical = false
                options.IncludeInitial (1, 1) logical = false
            end
            %
            fcastSpan = datex.ensureSpan(fcastSpan);
            [forecaster, tabulator] = this.prepareForecaster( ...
                fcastSpan, ...
                stochasticResiduals=options.StochasticResiduals, ...
                includeInitial=options.IncludeInitial ...
            );
            %
            numPresampled = this.NumPresampled;
            shortY = cell(1, numPresampled);
            shortU = cell(1, numPresampled);
            initY = cell(1, numPresampled);
            for i = 1 : numPresampled
                sample = this.Presampled{i};
                [shortY{i}, shortU{i}, initY{i}] = forecaster(sample);
            end
            
            [varargout{1:nargout}] = tabulator(shortY, shortU, initY);
        end%


        function [shortY, shortU, initY, draw] = forecast4S(this, sample, longYXZ, forecastStartIndex, forecastHorizon, options)
            arguments
                this
                sample
                longYXZ (1, 3) cell
                forecastStartIndex (1, 1) double
                forecastHorizon (1, 1) double
                %
                options.StochasticResiduals (1, 1) logical
                options.Order (1, 1) double {mustBeInteger, mustBePositive}
            end
            %
            unitDim = 2;
            meta = this.Meta;
            draw = this.Estimator.UnconditionalDrawer(sample, forecastStartIndex, forecastHorizon);
            numUnits = meta.NumSeparableUnits;
            shortY = cell(1, numUnits);
            shortU = cell(1, numUnits);
            initY = cell(1, numUnits);

            for i = 1 : numUnits
                %
                % Extract unit-specific data
                %
                unitYXZ = [meta.extractUnitFromCells(longYXZ(1), i, dim=3), longYXZ(2), longYXZ(3)];
                unitSigma = meta.extractUnitFromCells(draw.Sigma, i, dim=3);
                unitA = meta.extractUnitFromCells(draw.A, i, dim=3);
                unitC = meta.extractUnitFromCells(draw.C, i, dim=3);
                %
                % Generate unit-specific residuals
                %
                shortU{i} = system.generateResiduals( ...
                    unitSigma ...
                    , stochasticResiduals=options.StochasticResiduals ...
                );
                %
                % Run unit-specific forecast
                %
                [shortY{i}, initY{i}] = system.forecastMA( ...
                    unitA, unitC, unitYXZ, shortU{i} ...
                    , order=options.Order ...
                );
            end
            shortY = cat(unitDim, shortY{:});
            shortU = cat(unitDim, shortU{:});
            initY = cat(unitDim, initY{:});
        end%

    end


    methods
        function varargout = estimateResiduals(this, varargin)
%{
% # calculateResiduals
%
% {==Calculate reduced-form residuals==}
%
%}
            meta = this.Meta;
            longYXZ = this.getLongYXZ();
            function [Y4S, sample] = calculate4S(sample)
                [Y4S, sample] = this.estimateResiduals4S(sample, longYXZ);
            end%
            options = [{"includeInitial", true}, varargin];
            [varargout{1:nargout}] = this.tabulateSamples( ...
                "calculator", @calculate4S, ...
                "span", meta.ShortSpan, ...
                "variantDim", 3, ...
                "initiator", @nan, ...
                "dimNames", {meta.ResidualNames}, ...
                options{:} ...
            );
        end%


        function [u, sample] = estimateResiduals4S(this, sample, longYXZ)
            meta = this.Meta;
            draw = this.Estimator.HistoryDrawer(sample);
            numUnits = meta.NumSeparableUnits;
            u = cell(1, numUnits);
            for i = 1 : numUnits
                unitYXZ = [meta.extractUnitFromCells(longYXZ(1), i), longYXZ(2), longYXZ(3)];
                unitA = meta.extractUnitFromCells(draw.A, i);
                unitC = meta.extractUnitFromCells(draw.C, i);
                u{i} = system.calculateResiduals( ...
                    unitA, unitC, unitYXZ ...
                    , hasIntercept=meta.HasIntercept ...
                    , order=meta.Order ...
                );
            end
            u = cat(2, u{:});
        end%


        function varargout = calculateResiduals(this, varargin)
            [varargout{1:nargout}] = this.estimateResiduals(varargin{:});
        end%


        function checkForecastSpan(this, fcastStart, fcastEnd)
            beforeStart = datex.shift(fcastStart, -1);
            if ~any(beforeStart == this.Meta.ShortSpan)
                error("Forecast start period out of range.");
            end
            if ~this.Meta.HasExogenous
                return
            end
            if ~any(fcastEnd == this.DataHolder.Span)
                error("Forecast end period out of range.");
            end
        end%

    end

end

