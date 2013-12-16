function D = distmat(obj)
% DISMAT - Distances between nodes of a VAR model
%
% D = distmat(obj)
%
% 
% Where
%
% A is the distance matrix, i.e. a matrix whose (i,j) entry contains the
% distance from the jth node towards the ith node. 
%
%
% Note:
%
% * This method makes use of the BGL MATLAB toolbox, available at:
%   http://dgleich.github.com/matlab-bgl/
%
% See also: adjmat, floyd_warshall_all_sp

% Documentation: class_var_abstract_var.txt
% Description: Distances between network nodes


D = floyd_warshall_all_sp(sparse(adjacency_matrix(obj)));

end