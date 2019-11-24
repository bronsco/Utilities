function numberOfXRegDegree = calculateNumberXRegChoosen(obj)
% Auswertung wie complex die Modelle sind
% Idee ist zu überprüfen, ob die Zentrierung der Lokalen Modelle dazu führt,
% dass eher Regressoren mit geringerem Grad ausgesucht werden.

idxReg = sum(obj.xRegressorExponentMatrix,2);


numberOfXRegressorsChoosen = sum(cell2mat({obj.localModels(obj.leafModels).parameter})~=0,2);

numberOfXRegDegree = numberOfXRegressorsChoosen(1,:);
numberOfXRegressorsChoosen(1,:) = [];


numberOfXRegDegreeCounter = zeros(1,max(idxReg));
if length(idxReg) == length(numberOfXRegressorsChoosen)
    
    for counter = 1:length(idxReg)
        numberOfXRegDegreeCounter(idxReg(counter)) = numberOfXRegDegreeCounter(idxReg(counter)) + numberOfXRegressorsChoosen(counter);
    end
else
    error
end
numberOfXRegDegree = [numberOfXRegDegree numberOfXRegDegreeCounter];