function cvsets=createCrossValidationSets(numSamples,kfold)
%   function cvsets=createCrossValidationSets(numSamples,kfold)

%	Sets-up the "folds" for performing cross-validation by creating kfold
%	training/validation sets so as to grant that each sample within the dataset
%	is used once and only once is put into  validation set.
%
%   INPUT
%   numSamples  - total number of samples in the dataset
%   kfold       - number (k) of bins to create
%
%   OUTPUT
%   cvsets  - 	is a cell of structs. Each cell represents a test within the cross validation
%			  	cvsets{i}.tr contains, for the i-th test, the index (with respect to the dataset)
%				of samples to be used for training whilst cvsets{i}.vd contains indexes to be
%				used for validation
%
%	Marco Vannucci
%	mvannucci@sssup.it


for i=1:kfold-1
    numSamplesPerFold(i)=floor(numSamples/kfold);
end
numSamplesPerFold(kfold)=numSamples-floor(numSamples/kfold)*(kfold-1);

%   do una mescolata
indici=randperm(numSamples)

%   ora li prendo in gruppi
presi=0;
for i=1:kfold
    cvsets{i}.vd=indici(presi+1:presi+numSamplesPerFold(i));
    cvsets{i}.tr=setdiff((1:numSamples),cvsets{i}.vd);
    cvsets{i}.tr=cvsets{i}.tr(randperm(length(cvsets{i}.tr)));
    presi=presi+numSamplesPerFold(i);
end