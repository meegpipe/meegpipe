function [condIDout, condNames] = conditions()

import batman.*;
import misc.dlmread;
import mperl.file.spec.catfile;
import mperl.join;

fName = catfile(root_path, 'data', 'conditions.csv');
[condSpecs, varNames, condID] = dlmread(fName, ',', 0, 1);

varNames = varNames(2:end);

% Create some nice condition names
condNames = cell(size(condID));
dims = nan(1, numel(varNames));
for i = 1:numel(dims)
   dims(i) = numel(unique(condSpecs(:,i))); 
end
condNames = reshape(condNames, dims);
condIDout = cell(size(condID));

for i = 1:numel(condNames)
    tmpName = '';
    for j = 1:numel(varNames)
        thisLevel = condSpecs(i,j);
        tmpName = [tmpName varNames{j} num2str(thisLevel) '_']; %#ok<AGROW>
    end
    tmpName(end) = []; 
    eval(['idx = sub2ind(dims,' join(',', condSpecs(i,:)+1) ');']);
    condNames(idx) = {tmpName};
    condIDout(idx) = condID(i);
end


end