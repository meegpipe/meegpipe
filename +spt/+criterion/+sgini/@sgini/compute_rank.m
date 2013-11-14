function rankValue = compute_rank(~, sptObj, varargin)

M = bprojmat(sptObj);

rankValue = misc.gini_idx(M);

end