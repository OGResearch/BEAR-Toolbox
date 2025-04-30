function [data, favar, indexnM] = ogr_favar_gensample2(longY, endo, lags, favar)

    favar.data_exfactors = longY;
    favar.variablestrings_factorsonly = (1:favar.numpc)';
    favar.variablestrings_factorsonly_index = [true(favar.numpc, 1) ; false(size(longY, 2), 1)];
    favar.variablestrings_exfactors = (favar.numpc+1 : favar.numpc + size(longY,2))';
    favar.variablestrings_exfactors_index = [false(favar.numpc, 1); true(size(longY, 2), 1)];

    indexnM = repmat(favar.variablestrings_factorsonly_index, 1, lags);
    indexnM = find(indexnM==1);

    if favar.blocks
        tmp = [];

        for jj = 1:favar.nbnames
            pattern = favar.bnames(jj) + "_";
            favar.blocks_index{jj,1} = find(contains(endo, pattern));
            tmp = [tmp favar.XZ_block{jj}];
        end

       data = [tmp favar.data_exfactors];

    else
        
        data = [favar.XZ favar.data_exfactors];
    
    end
    
end