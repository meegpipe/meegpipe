function rankValue = compute_rank(~, ~, tSeries, varargin)


import misc.gini_idx;

rankValue = gini_idx(tSeries(:,:)');

end