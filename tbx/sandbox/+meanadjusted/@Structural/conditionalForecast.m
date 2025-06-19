
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
    initorigY = initYXZ{1};
    initX = initYXZ{2};

    cfconds = conditional.createConditionsCF(meta, options.Plan, options.Conditions, ...
        shortFcastSpan);
    cfshocks = conditional.createShocksCF(meta, options.Plan, shortFcastSpan);
    cfblocks = conditional.createBlocksCF(cfconds, cfshocks);

    legacyOptions = struct();
    legacyOptions.order = meta.Order;
    legacyOptions.cfconds = [];
    legacyOptions.cfblocks = [];
    legacyOptions.cfshocks = [];

    numPresampled = this.NumPresampled;
    progressMessage = sprintf("Conditional forecast [%g]", numPresampled);

    fcastY = cell(1, numPresampled);
    fcastE = cell(1, numPresampled);
    
    if options.Contributions
        [contributor, contribs, precontribs] ...
            = this.prepareForContributions(shortFcastSpan, options.Precontributions);
    end

    pbar = progress.Bar(progressMessage, numPresampled);
    for i = 1 : numPresampled
        sample = this.Presampled{i};
        draw = this.ConditionalDrawer(sample, fcastStartIndex, fcastHorizon);
        if ~isempty(cfconds)
            legacyOptions.cfconds = cfconds;
        end
        if ~isempty(cfshocks)
            legacyOptions.cfshocks = cfshocks;
        end
        if ~isempty(cfblocks)
            legacyOptions.cfblocks = cfblocks;
        end
        beta = meta.extractUnitFromCells(draw.beta, 1, dim=2);
        
        B = reshape(beta{1}, [], numY);
        A = B(1:numL, :);
        C = B(numL+1:end, :);
        initY = initorigY - initX*C; 

        [Y, E] = conditional.forecastMA(transpose(sample.D), A, ...
            initY, fcastHorizon, legacyOptions);
        fcastY{i} = [fcastY{i}, Y];
        fcastE{i} = [fcastE{i}, E];

        % {
        if options.Contributions
            A = cell(1, fcastHorizon);
            C = cell(1, fcastHorizon);
            for k = 1 : fcastHorizon
                B = reshape(beta{k}, [], numY);
                A{k} = B(1:numL, :);
                C{k} = B(numL+1:end, :);
            end
            Contribs = contributor(A, C, D, E, [], initY, precontribs(:, :, :));
            contribs{i} = [contribs{i}, Contribs];
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

