function [FY, favar, indexnM] = initializeFAVAR(longY, longZ, favar, p , meta)

    if strcmp(meta.BlockType, "blocks")
       favar.blocks = true;
    elseif strcmp(meta.BlockType, "slowfast")
       favar.blocks = false;
    end

    favar.nfactorvar = meta.NumReducibleNames;
    favar.X = longZ;

    favar.numpc = meta.NumFactorNames;

    %gensample 1
    [favar] = bear.ogr_favar_gensample1(favar, meta);

    %gensample2
    endo = [meta.FactorNames, meta.EndogenousNames];     
    [data, favar, indexnM] = bear.ogr_favar_gensample2(longY, endo, p, favar);

    % gensample 3
    [FY, favar] = bear.ogr_favar_gensample3(data, favar);
    

    
end
