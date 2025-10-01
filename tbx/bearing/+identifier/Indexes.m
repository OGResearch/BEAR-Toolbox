
classdef Indexes < handle

    properties
        EndogenousNames (1, 1) struct = struct()
        EndogenousConcepts (1, 1) struct = struct()
        ExogenousNames (1, 1) struct = struct()
        Units (1, 1) struct = struct()
        ShockNames (1, 1) struct = struct()
        ShockConcepts (1, 1) struct = struct()
        HistoryPeriods (1, 1) struct = struct()
    end


    methods
        function this = Indexes(meta)
            arguments
                meta (1, 1) model.Meta
            end
            %
            this.EndogenousNames = textual.createDictionary(meta.EndogenousNames);
            this.EndogenousConcepts = textual.createDictionary(meta.EndogenousConcepts);
            this.ExogenousNames = textual.createDictionary(meta.ExogenousNames);
            this.Units = textual.createDictionary(meta.Units);
            this.ShockNames = textual.createDictionary(meta.ShockNames);
            this.ShockConcepts = textual.createDictionary(meta.ShockConcepts);
            this.HistoryPeriods = textual.createDictionary(datex.toFieldable(meta.ShortSpan));
        end%
    end

end

