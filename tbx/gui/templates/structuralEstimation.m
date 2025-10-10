
%% Create an identification object 

identifier = identifier.?IDENTIFIER?( ...
    ?IDENTIFIER_SETTINGS?
);


%% Create a structural model 

structModel = Structural( ...
    reducedForm=redModel ...
    , identifier=identifier ...
);
printObject(structModel);


%% Initialize and presample the structural model 

structModel.initialize();
info = structModel.presample(?NUM_SAMPLES?);
printInfo(info);

?SAVE_MAT?save(fullfile(outputFolder, "structuralModel.mat"), "structModel");

