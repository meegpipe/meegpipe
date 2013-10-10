function [rankVal, ev] = compute_rank(obj, data, ev)
% COMPUTE_RANK - Ranks bad epochs according to a simple statistic
%
%
% See also: minmax


import meegpipe.node.bad_epochs.bad_epochs;
import misc.eta;

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

stat1 = get_config(obj, 'Statistic1');
stat2 = get_config(obj, 'Statistic2');

if nargin < 3 || isempty(ev),
    warning('bad_epochs:NoEpochs', ...
        'There are no epochs in this data: nothing done!');
    rankVal = nan(1, numel(ev));
    return;
end

if verbose,
    fprintf([verboseLabel 'Computing epochs statistics...']);
    clear +misc/eta;
    tinit = tic;
end

[dataEpochs, ~, ~, ~, ev] = epoch_get(data, ev, false);

statVal2 = nan(1, size(dataEpochs, 3));

for i = 1:size(dataEpochs, 3)
    
    statVal1 = zeros(1, size(dataEpochs, 1));
    for j = 1:size(dataEpochs, 1)
        statVal1(j) = stat1(squeeze(dataEpochs(j, :, i)));
    end
    
    statVal2(i) = stat2(statVal1);  
    
    if verbose,
        eta(tinit, size(dataEpochs, 3), i);
    end
    
end



if verbose,
    clear +misc/eta;
    fprintf('\n\n');
end

rankVal = statVal2;

end

