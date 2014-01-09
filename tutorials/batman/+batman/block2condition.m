function [condID, condName] = block2condition(subj, blockID)
% BLOCK2CONDITION - Convert subject ID + block ID into a condition ID/name
% ===
%
% See also: batman

import misc.dlmread;
import mperl.file.spec.catfile;
import batman.conditions;
import batman.protocol;
import mperl.join;

if nargin < 2 || numel(blockID) ~= 1,
    error('blockID must be a single block index');
end

% In /data/protocol the block IDs are encoded as 1..12, i.e. the two break
% blocks are not considered
if blockID > 9,
    blockID = blockID -2 ;
elseif blockID > 4,
    blockID = blockID - 1;
end

[condIDList, condNameList] = conditions;

[blockIDList, condIDMap, subjID] = protocol(subj);

if isempty(subjID),
    warning('block2condition:InvalidSubjectID', ...
        'Invalid subject ID: %d', subj);
    condID   = [];
    condName = [];
    return;
end

[isMember, loc] = ismember(['block' num2str(blockID)], blockIDList);

if ~isMember,
    warning('block2condition:InvalidBlockID', ...
        'Invalid block ID: %d', blockID);
    condID   = [];
    condName = [];
    return;
end

condID     = condIDMap(loc);
condName   = condNameList(ismember(condIDList, condID));

if isempty(condName),
    warning('block2condition:InvalidBlockID', ...
        'Block %d corresponds to invalid condition ID ''%s''', ...
        blockID, condID{1});
    condID   = [];
    condName = [];
    return;
end

condName = condName{1};
condID   = condID{1};

end