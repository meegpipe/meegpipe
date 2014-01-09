function [blockID, condID, subjID] = protocol(subjID)


import misc.dlmread;
import batman.*;
import mperl.file.spec.catfile;
import mperl.join;

fName = catfile(root_path, 'data', 'protocol.csv');
[prot, blockID2] = dlmread(fName, ',');

blockID  = blockID2;
subjID2  = prot(:,1);

[isMember, loc] = ismember(subjID, subjID2);

subjID(~isMember) = [];
loc(~isMember) = [];

prot = prot(loc, :);

condID = cell(numel(subjID), numel(blockID));
for i = 1:size(condID,1)
   condID(i,:) = arrayfun(@(x) {['cond' num2str(x)]}, prot(i,:));
end

end