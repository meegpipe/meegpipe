function A = dirmat(obj, varargin)
% DIRMAT - Directionality Matrix of a VAR model
%
%
% A = dirmat(obj);
% A = dirmat(obj, 'File', 'mynetwork.txt');
%
%
% Where
%
% A is the directionality matrix, i.e. a matrix a matrix with ones only in
% those directions where an asymmetric connection exists. The ones are
% located in the direction of the strongest connection.
%
% The optional key 'File' can be used to indicate that the adjancency
% pattern should be stored as A Cytoscape-compatible text file [1].
%
%
% References:
%
% [1] Cytoscape network visualization software: http://www.cytoscape.org/
%
%
% See also: adjmat, distmat, var.abstract_var

% Documentation: class_var_abstract_var.txt
% Description: Directionality Matrix


import misc.process_arguments;

opt.file        = [];
opt.threshold   = eps;
[~, opt] = process_arguments(opt, varargin);

coeffs = reshape(var_coefficients(obj), [obj.NbDims, obj.NbDims, obj.Order]);
coeffs = mean(abs(coeffs), 3);
A = zeros(obj.NbDims);
for i = 1:obj.NbDims
    for j = 1:obj.NbDims
        if coeffs(i,j)>opt.threshold && coeffs(i,j) >= coeffs(j,i),
            A(i,j) = 1;
        end
    end
end

b = A;
if ~isempty(opt.file),
    fid = fopen(opt.file, 'w');
    try
        for i = 1:size(b,2)
            for j = 1:size(b,1)
                if i==j, continue; end
                if b(j,i) > eps,
                    fprintf(fid, [num2str(i) '\tpd\t' num2str(j) '\n']);
                end
            end
        end
        % Now the lonely nodes
        for i = 1:size(b,1)
           idx = setdiff(1:size(b,1),i);
           if all(b(i,idx) < 1) && all(b(idx,i)<1),
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