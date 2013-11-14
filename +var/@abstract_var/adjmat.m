function A = adjmat(obj, varargin)
% ADJMAT - Adjancency matrix of a VAR model
%
%
% A = adjmat(obj);
%
% A = adjmat(obj, 'File', 'mynetwork.txt');
%
%
% Where
%
% A is the adjacency matrix, i.e a matrix with ones wherever a connection
% between a pair of network nodes exist and zeros otherwise.
%
% The optional key 'File' can be used to indicate that the adjancency
% pattern should be stored as A Cytoscape-compatible text opt.file [1].
%
%
% References:
%
% [1] Cytoscape network visualization software: http://www.cytoscape.org/
%
%
% See also: dirmat, distmat, var.abstract_var


% Documentation: class_var_abstract_var.txt
% Description: Adjancency Matrix

import misc.process_arguments;

opt.file      = [];
opt.threshold = eps;
[~, opt] = process_arguments(opt, varargin);

coeffs = reshape(var_coefficients(obj), [obj.NbDims, obj.NbDims, obj.Order]);
coeffs = max(abs(coeffs), [], 3);
A      = double(coeffs > opt.threshold);

if ~isempty(opt.file),
    fid = fopen(opt.file, 'w');
    try
        for i = 1:size(A,2)
            for j = 1:size(A,1)
                if i==j, continue; end
                if A(j,i) > eps,
                    fprintf(fid, [num2str(i) '\tpd\t' num2str(j) '\n']);
                end
            end
        end
        % Now the lonely nodes
        for i = 1:size(A,1)
           idx = setdiff(1:size(A,1),i);
           if all(A(i,idx) < 1) && all(A(idx,i)<1),
               fprintf(fid, [num2str(i) '\tpd\t' num2str(i) '\n']);
           end
        end
    catch ME
        fclose(fid);
        rethrow(ME);
    end
    fclose(fid);
end



end

