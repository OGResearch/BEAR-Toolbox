
function [fcastTbl, contribsTbl] = conditionalForecast(this, fcastSpan, options)

    arguments
        this
        fcastSpan (1, :) datetime

        options.Conditions (:, :) timetable
        options.Plan = []
        options.IncludeInitial (1, 1) logical = true

        options.Contributions (1, 1) logical = false
        options.Precontributions = []
    end

    VARIANT_DIM = 3;

    meta = this.Meta;
    numY = meta.NumEndogenousNames;
    order = meta.Order;
    numL = numY * order;
    shortFcastSpan = datex.ensureSpan(fcastSpan);
    fcastStart = shortFcastSpan(1);
    longFcastSpan = datex.longSpanFromShortSpan(shortFcastSpan, meta.Order);
    fcastStartIndex = datex.diff(fcastStart, meta.ShortStart) + 1;
    fcastHorizon = numel(shortFcastSpan);
    initSpan = datex.initSpanFromShortSpan(shortFcastSpan, meta.Order);
    initYXZ = this.getSomeYXZ(initSpan);
    initY = initYXZ{1};

    cfconds = conditional.createConditionsCF(meta, options.Plan, options.Conditions, shortFcastSpan);
    cfshocks = conditional.createShocksCF(meta, options.Plan, shortFcastSpan);
    cfblocks = conditional.createBlocksCF(cfconds, cfshocks);

    legacyOptions = struct();
    legacyOptions.order = meta.Order;
    legacyOptions.cfconds = [];
    legacyOptions.cfblocks = [];
    legacyOptions.cfshocks = [];

    numPresampled = this.NumPresampled;
    progressMessage = sprintf("Conditional forecast [%g]", numPresampled);

    if ~isempty(cfconds)
        cfconds = reshape(cfconds, size(cfconds, 1), [], 1);
    end
    if ~isempty(cfshocks)
        cfshocks = reshape(cfshocks, size(cfshocks, 1), [], 1);
    end
    if ~isempty(cfblocks)
        cfblocks = reshape(cfblocks, size(cfblocks, 1), [], 1);
    end

    fcastY = cell(1, numPresampled);
    fcastE = cell(1, numPresampled);

    
    % if options.Contributions
    %     [contributor, contribs, precontribs] ...
    %         = this.prepareForContributions(shortFcastSpan, options.Precontributions);
    % end

    pbar = progress.Bar(progressMessage, numPresampled*numUnits);
    for i = 1 : numPresampled
        sample = this.Presampled{i};
        draw = this.ConditionalDrawer(sample, fcastStartIndex, fcastHorizon);
        if ~isempty(cfconds)
            legacyOptions.cfconds = cfconds(:, :, 1);
        end
        if ~isempty(cfshocks)
            legacyOptions.cfshocks = cfshocks(:, :, 1);
        end
        if ~isempty(cfblocks)
            legacyOptions.cfblocks = cfblocks(:, :, 1);
        end
        unitInitY = initY(:, :, 1);
        unitD = sample.D(:, :, 1);
        unitBeta = meta.extractUnitFromCells(draw.beta, 1, dim=2);
        unitB = reshape(unitBeta{:}, [], numY);
        [unitY, unitE] = conditional.forecastMA(transpose(unitD), unitB, unitInitY, fcastHorizon, legacyOptions);
        fcastY{i} = [fcastY{i}, unitY];
        fcastE{i} = [fcastE{i}, unitE];

        %{
        if options.Contributions
            unitA = cell(1, fcastHorizon);
            unitC = cell(1, fcastHorizon);
            for k = 1 : fcastHorizon
                unitB = reshape(unitBeta{k}, [], numY);
                unitA{k} = unitB(1:numL, :);
                unitC{k} = unitB(numL+1:end, :);
            end
            unitContribs = contributor(unitA, unitC, unitD, unitE, fcastX, unitInitY, precontribs(:, :, :, i));
            contribs{i} = [contribs{i}, unitContribs];
        end

        %}
        pbar.increment();
    end

    fcastY = cat(VARIANT_DIM, fcastY{:});
    fcastE = cat(VARIANT_DIM, fcastE{:});
    outNames = [meta.EndogenousNames, meta.ShockNames];
    outData = [fcastY, fcastE];
    outSpan = shortFcastSpan;
    if options.IncludeInitial
        outSpan = longFcastSpan;
        initData = [repmat(initY(:, :), 1, 1, numPresampled), zeros(order, numY, numPresampled)];
        outData = [initData; outData];
    end

    fcastTbl = tablex.fromNumericArray(outData, outNames, outSpan, variantDim=VARIANT_DIM);

    contribsTbl = [];
    if options.Contributions
        contribsTbl = this.tabulateContributions(contribs, shortFcastSpan);
    end

end%

