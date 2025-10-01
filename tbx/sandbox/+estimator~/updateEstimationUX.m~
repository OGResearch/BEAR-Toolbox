
function excelData = updateEstimationUX()

    UX_FILE_PATH = "BEAR6-EstimationUX.xlsx";
    SHEET = "Reduced-form estimation";
    RANGE = "B2";

    excelData = prepareExcelData();

    writecell( ...
        excelData ...
        , UX_FILE_PATH ...
        , sheet=SHEET ...
        , range=RANGE ...
    );

end%


function excelData = prepareExcelData()

    collectionClasses = collectEstimators();
    numClasses = numel(collectionClasses);
    collectionExcelData = cellfun(@createExcelData, collectionClasses, uniformOutput=false);
    numRows = max(cellfun(@height, collectionExcelData));
    excelData = cell.empty(numRows, 0);
    for i = 1 : numClasses
        add = repmat({""}, numRows, 2);
        add(1:height(collectionExcelData{i}), :) = collectionExcelData{i};
        excelData = [excelData, add];
    end

end%


function [collection, invalid] = collectEstimators()

    collection = {};
    invalid = string.empty(1, 0);
    for className = reshape(listClasses(), 1, [])
        x = estimator.(className)();
        collection{end+1} = x;
    end

end%


function excelData = createExcelData(estimatorClass)

    NUM_HEADER_ROWS = 4;

    settingNames = reshape(string(fieldnames(estimatorClass.Settings)), 1, []);
    numSettings = numel(settingNames);

    excelData = repmat({""}, NUM_HEADER_ROWS + numSettings, 2);
    excelData{1, 2} = false;
    excelData{2, 2} = estimatorClass.ShortClassName;
    try
        excelData{3, 2} = estimatorClass.Description;
    catch
        excelData{3, 2} = excelData{2, 1};
    end
    excelData{4, 2} = estimatorClass.CanHaveDummies;

    for i = 1 : numSettings
        excelData{NUM_HEADER_ROWS + i, 1} = settingNames(i);
        excelData{NUM_HEADER_ROWS + i, 2} = estimatorClass.Settings.(settingNames(i));
    end

end%


function list = listClasses()

    list = [
        "Ordinary"
        "Flat"
        "NormalDiffuse"
        "NormalWishart"
        "IndNormalWishart"
        "Minnesota"

        "BetaTV"
        "GeneralTV"
        "CarrieroSV"
        "CogleySargentSV"
        "RandomInertiaSV"

        "HierarchicalPanel"
        "MeanOLSPanel"
        "NormalWishartPanel"
        "ZellnerHongPanel"
        "StaticCrossPanel"
        "DynamicCrossPanel"

        ... "NormalWishart_FAVAR"
    ];

end%

