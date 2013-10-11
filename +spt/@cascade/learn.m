function obj = learn(obj, data)
% LEARN - Learn the spatial transform basis functions
%
% obj = learn(obj, data)
%
% Where
%
% DATA is a numeric matrix (observations columnwise) or a pointset
% container object (e.g. a pset.physioset object)
%
% See also: spt.cascade

% Description: Learns spatial basis functions
% Documentation: class_spt_cascade.txt

import misc.ispset;

if iscell(data),
    obj = learn_dualreg(obj, data);
    return;
end

if ispset(data), data = data(:,:); end

W = eye(size(data,1));
for i = 1:numel(obj.Node)
    obj.Node{i} = learn(obj.Node{i}, data);  
    if ~isempty(obj.Criterion{i}),
        isSelected = select(obj.Criterion{i}, obj.Node{i}, data);
        obj.Node{i} = deselect(obj.Node{i}, 'all');
        obj.Node{i} = select(obj.Node{i}, find(isSelected));
    end
    data = proj(obj.Node{i}, data);   
    W = projmat(obj.Node{i})*W;    
end

A = bprojmat(obj.Node{end});
for i = (numel(obj.Node)-1):-1:1
   A = bprojmat(obj.Node{i})*A; 
end

obj = set_basis(obj, W, A);



end