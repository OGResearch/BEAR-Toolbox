

function status = canBeIdentified()

    currentModule = gui.getCurrentModule();
    if currentModule == ""
        status = false;
        return
    end

    estimatorObj = gui.getCurrentEstimatorObj();
    status = isequal(estimatorObj.CanBeIdentified, true);

end%

