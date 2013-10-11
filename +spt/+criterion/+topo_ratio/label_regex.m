function idx = label_regex(sens, regex, negated)

if nargin < 3 || isempty(negated), negated = false; end

if ~iscell(regex), regex = {regex}; end

sensLabels = labels(sens);

isSelected = false(numel(sensLabels), 1);
for i = 1:numel(regex)
   isSelected = isSelected | cellfun(...
       @(x) ~isempty(regexp(x, regex{i}, 'once')), sensLabels);
end

if negated, isSelected = ~isSelected; end

idx = find(isSelected);

end