function [W, A, selection] = learn_basis(obj, data, varargin)

import ewasobi.ewasobi;

W = ewasobi(data, get_config(obj, 'AROrder'));
A = pinv(W);
selection = 1:size(W,1);

end