
classdef Verifiables ...
    < base.Identifier

    properties (Constant)
        DEFAULT_MAX_CANDIDATES = 100
        DEFAULT_TRY_FLIP_SIGNS = true
    end


    properties (SetAccess = protected)
        TestStrings (:, 1) string
        VerifiableTests
        ExactZeros = base.identifier.ExactZeros()
        SignRestrictionsTable (:, :) table
        %
        MaxCandidates (1, 1) double {mustBePositive} = base.identifier.Verifiables.DEFAULT_MAX_CANDIDATES
        TryFlipSigns (1, 1) logical = base.identifier.Verifiables.DEFAULT_TRY_FLIP_SIGNS
    end


    methods
        function this = Verifiables(testStrings, inputs, options)
            arguments
                testStrings (:, 1) string = string.empty(0, 1)
                %
                inputs.SignRestrictionsTable = []
                inputs.ExactZeros = []
                inputs.ExactZerosTable = []
                %
                options.MaxCandidates (1, 1) double = base.identifier.Verifiables.DEFAULT_MAX_CANDIDATES
                options.TryFlipSigns (1, 1) logical = base.identifier.Verifiables.DEFAULT_TRY_FLIP_SIGNS
                % options.ShortCircuit (1, 1) logical = base.identifier.VerifiableTests.DEFAULT_SHORT_CIRCUIT
            end
            %
            this.TestStrings = testStrings;
            this.MaxCandidates = options.MaxCandidates;
            this.TryFlipSigns = options.TryFlipSigns;
            this.SignRestrictionsTable = inputs.SignRestrictionsTable;
            this.addExactZeros(inputs);
            %
        end%

        function whenPairedWithModel(this, modelS)
            arguments
                this
                modelS (1, 1) base.Structural
            end
            if ~isempty(this.ExactZeros)
                this.ExactZeros.whenPairedWithModel(modelS);
            end
            %
            this.addSignRestrictions(modelS);
            this.VerifiableTests = base.identifier.VerifiableTests(this.TestStrings);
        end%

        function initializeSampler(this, modelS)
            %[
            arguments
                this
                modelS (1, 1) base.Structural
            end
            %
            reducedFormSampler = modelS.ReducedForm.Estimator.Sampler;
            identificationDrawer = modelS.ReducedForm.Estimator.IdentificationDrawer;
            historyDrawer = modelS.ReducedForm.Estimator.HistoryDrawer;
            meta = modelS.Meta;
            numShocks = modelS.Meta.NumShockNames;
            order = meta.Order;
            hasIntercept = meta.HasIntercept;
            longYX = modelS.getLongYX();
            [longY, longX] = longYX{:};
            %
            [testFunc, occurrence] = this.VerifiableTests.buildTestEnvironment(modelS.Meta);
            has = struct();
            for n = ["SHKRESP", "FEVD", "SHKEST", "SHKCONT"]
                has.(n) = isfield(occurrence, n);
            end
            %
            % Initialize the ExactZeros object without a warning
            this.ExactZeros.deinitialize();
            this.ExactZeros.initialize(modelS);
            candidator = this.ExactZeros.getCandidator();
            %
            %
            function sample = samplerS()
                % Loop until a valid sample-candidate is found
                while true
                    sample = reducedFormSampler();
                    identificationDraw = identificationDrawer(sample);
                    sample.IdentificationDraw = identificationDraw;
                    if has.SHKEST
                        historyDraw = historyDrawer(sample);
                        residuals = system.calculateResiduals( ...
                            historyDraw.A, historyDraw.C, longY, longX ...
                            , hasIntercept=hasIntercept ...
                            , order=meta.Order ...
                        );
                    end

                    this.SampleCounter = this.SampleCounter + 1;
                    %
                    Sigma = identificationDraw.Sigma;
                    Sigma = (Sigma + Sigma')/2;
                    P = chol(Sigma);
                    %
                    propertyValues = struct();
                    initCandidateCounter = this.CandidateCounter;
                    while (this.CandidateCounter - initCandidateCounter) < this.MaxCandidates
                        %
                        % Generate a candidate D based on the factor matrix P
                        sample.D = candidator(P);
                        this.CandidateCounter = this.CandidateCounter + 1;


                        if has.SHKRESP
                            propertyValues.SHKRESP = system.filterPulses(identificationDraw.A, sample.D);
                        end
                        %
                        if has.FEVD
                            propertyValues.FEVD = system.finiteFEVD(propertyValues.SHKRESP);
                        end
                        %
                        if has.SHKEST
                            % residuals = shocks * D => shocks = residuals / D
                            propertyValues.SHKEST = residuals / sample.D;
                        end
                        %
                        if has.SHKCONT
                            propertyValues.SHKCONT = system.contributionsShocks(historyDraw.A, sample.D, propertyValues.SHKEST);
                        end


                        success = testFunc(propertyValues);
                        if all(success)
                            return
                        end
                        %
                        % Try flipping signs of shocks one by one
                        numSuccess = nnz(success);
                        for i = 1 : numShocks
                            %
                            % Store copies of the current state for a possible
                            % reversal
                            numSuccess0 = numSuccess;
                            D0 = sample.D;
                            propertyValues0 = propertyValues;
                            %
                            %
                            % Flip sign for the i-th shock
                            % The cost of ANY abstraction here is extremely
                            % high. Inline everything for quasi-optimal
                            % performance.
                            sample.D(i, :) = -sample.D(i, :);
                            %
                            if has.SHKRESP
                                propertyValues.SHKRESP(:, :, i) = -propertyValues.SHKRESP(:, :, i);
                            end
                            %
                            if has.SHKEST
                                propertyValues.SHKEST(:, i) = -propertyValues.SHKEST(:, i);
                            end
                            %
                            %
                            % Evaluate the tests again with a flipped sign for
                            % the i-th shock
                            success = testFunc(propertyValues);
                            if all(success)
                                return
                            end
                            %
                            numSuccess = nnz(success);
                            %
                            % Keep the flipped sign only if it improves the number of
                            % successful tests; otherwise, revert to the
                            % original sign in the i-th shock
                            if numSuccess > numSuccess0
                                % Keep the flipped sign if improvement
                                % Do nothing
                            else
                                % Revert to the original sign if no improvement
                                numSuccess = numSuccess0;
                                sample.D = D0;
                                propertyValues = propertyValues0;
                            end
                        end
                    end
                end
            end%
            %
            this.Sampler = @samplerS;
            %]
        end%

        function addExactZeros(this, inputs)
            if ~isempty(inputs.ExactZeros)
                this.ExactZeros = inputs.ExactZeros;
                return
            end
            if ~isempty(inputs.ExactZerosTable)
                this.ExactZeros = base.identifier.ExactZeros(inputs.ExactZerosTable);
                return
            end
        end%

        function testStrings = addSignRestrictions(this, model)
            tbl = this.SignRestrictionsTable;
            if isempty(tbl)
                return
            end
            tablex.validateSignRestrictions(tbl, model=model);
            addTestStrings = base.identifier.SignRestrictions.toVerifiableTestStrings(tbl, model);
            addTestStrings = reshape(unique(string(addTestStrings), "stable"), [], 1);
            this.TestStrings = [this.TestStrings; addTestStrings];
        end%

    end

end

