function [W, A, selection, obj] = learn_basis(obj, data, varargin)


import jade.jader; 

W = jader(data);
A = pinv(W);

selection = 1:size(W,1);


end