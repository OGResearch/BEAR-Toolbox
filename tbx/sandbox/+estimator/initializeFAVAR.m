function [FY, favar, indexnM] = initializeFAVAR(longY, longZ, favar )
    
    [favar.l] = pca(longZ,'NumComponents', favar.numpc);
    favar.nfactorvar = size(longZ, 2);
    
    %identify factors: normalise loadings, compute factors following BBE 2005
    favar.l = sqrt(favar.nfactorvar) * favar.l;
    favar.XZ = longZ * favar.l / favar.nfactorvar;
    
    FY = [favar.XZ longY];
    
    favar.variablestrings_factorsonly = (1:favar.numpc)';
    favar.variablestrings_factorsonly_index = [true(favar.numpc, 1) ; false(size(longY, 2), 1)];
    favar.variablestrings_exfactors = (favar.numpc+1:size(FY, 2))';
    favar.variablestrings_exfactors_index = [false(favar.numpc, 1); true(size(longY, 2), 1)];
    favar.data_exfactors = longY;
    [FY, favar] = bear.ogr_favar_gensample3(FY, favar);

    indexnM = repmat(favar.variablestrings_factorsonly_index, 1, opt.p);
    indexnM = find(indexnM==1);
    
end
