function rankValue = compute_rank(obj, sptObj, tSeries, varargin)

import goo.globals;

origVerbose = globals.get.Verbose;
globals.set('Verbose', false);

criteria = get_config(obj, 'Criteria');
weights  = get_config(obj, 'Weights');


rankValue = zeros(size(tSeries,1),1);
tSeries = tSeries(:,:);

for i = 1:numel(criteria),
    
    thisRankValue = compute_rank(criteria{i}, sptObj, tSeries, varargin{:});
    thisRankValue = thisRankValue-min(thisRankValue);
    thisRankValue = thisRankValue./max(thisRankValue);
    rankValue = rankValue + weights(i)*thisRankValue(:);  
    
end

rankValue = rankValue-min(rankValue);
rankValue = rankValue./max(rankValue);

globals.set('Verbose', origVerbose);

end