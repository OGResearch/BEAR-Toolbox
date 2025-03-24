
% estimator.Base  Default values for common prior distribution settings

classdef (CaseInsensitiveProperties=true) Base < settings.Base

    properties

        % Number of burn-in draws
        %Bu
        Burnin (1, 1) double = 0 %Bu in BEAR5

        % Priors on exogenous variables flag
        %priorexogenous
        Exogenous (:, :) logical = false %% priorexogenous in BEAR5, controls wheter to use priors on exogenous

        % Block exogeneity flag
        % bex
        BlockExogenous (:, :) logical = false %bex in BEAR5, controls wheter to use block exogenity

        % Prior on first-order autoregression
        % ar
        Autoregression (:, 1) double = 0.8 %ar in BEAR5, the prior mean of the first lag

        % Overal tightness of priors
        % lambda1
        Lambda1 double = 0.1 %lambda1 in BEAR5 , contols the overal tightness of priors

        % Variable weighting
        % lambda2
        Lambda2 double = 0.5 %lambda2 in BEAR5, controls cross variable weightning
        
        % Leg decay
        % lambda3
        Lambda3 double = 1 %lambda 3 in BEAR5, controls leg decay

        % Exogenous variable tightness
        % lambda4
        Lambda4 (:, :) double = 100 %lambda4 in BEAR5, controls exogenous variable tightness

        % Block exogeneity shrinkage
        % lambda5
        Lambda5 double = 0.001 %lambda5 block exogeneity shrinkage hyperparameter

    end


    properties (Hidden)
        % Model has a constant term
        HasConstant (1, 1) logical = true %const in BEAR5

        % Number of lags
        Order (1, 1) double = 1 %lags in BEAR5
    end


    methods

        function this = Base(meta, varargin)
            if nargin == 0
                return
            end

            for i = 1 : 2 : numel(varargin)
                this.(varargin{i}) = varargin{i+1};
            end

            numY = meta.NumEndogenousNames;
            numX = meta.NumExogenousNames;
            numXI = numX + double(meta.HasIntercept);
            if isscalar(this.Exogenous)
                this.Exogenous = repmat(this.Exogenous, numY, numXI);
            end
            if isscalar(this.Lambda4)
                this.Lambda4 = repmat(this.Lambda4, numY, numXI);
            end
            if isscalar(this.Autoregression)
                this.Autoregression = repmat(this.Autoregression, numY, 1);
            end
        end%

    end

end

