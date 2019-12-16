% Copyright 2016 The MathWorks, Inc.

function synsets2words(convnet)
% This function converts ImageNet synset IDs to meaningful word 
% descriptions

synsetsFile = fullfile(fileparts(mfilename('fullpath')), '..', 'networks', 'synsetMap.mat');
url = 'http://www.image-net.org/api/text/wordnet.synset.getwords?wnid=%s';

% image net class names are synset IDs. Get the description instead
synsets = convnet.Layers(end).ClassNames;
synsetMap = containers.Map;
synsetWords = cell(1,numel(synsets));

fprintf(1,'Converting ImageNet synset IDs to meaningful word descriptions\n');
fprintf(1,['Processing %0',num2str(length(num2str(numel(synsets)))),'i of %i.\n'],0,numel(synsets));

for i = 1:numel(synsets)
    fprintf(1,['\b\b\b\b\b\b\b',repmat('\b',1,2*numel(num2str(numel(synsets)))),...
            ' %0',num2str(length(num2str(numel(synsets)))),'i of %i.\n'], i, numel(synsets));
    synsetWords{i} = urlread(sprintf(url,synsets{i}));
    synsetWords{i} = strtok(synsetWords{i},sprintf('\n'));
    synsetMap(synsets{i}) = synsetWords{i};
end

save(synsetsFile, 'synsetMap');