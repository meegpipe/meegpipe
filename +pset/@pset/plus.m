function y = plus(a, b)
% + Plus. 
%
%   A + B adds B to the contents of pset object A. B can be either a
%   numeric array or a pset object.
%
% See also: pset.pset


import misc.ispset;

% Check data dimensions
if ~all(size(a)==size(b)) && ~((prod(size(a))==1) || prod(size(b))==1), %#ok<PSIZE>
    error('pset:pset:plus:dimensionMismatch', 'Data dimensions do not match.');
end

if ~ispset(a),        
    tmp = a;
    a = b;
    b = tmp;    
end

y = a;

for i = 1:a.NbChunks
    [index, dataa] = get_chunk(a, i);
    if ispset(b),
        [~, datab] = get_chunk(b, i);
    elseif numel(b)==1,
        datab = b(1);
    else
        if a.Transposed,
            datab = b(index, :);
        else
            datab = b(:, index);
        end
    end    
    if a.Transposed,        
        s.subs = {index, 1:a.NbDims};        
    else
        s.subs = {1:a.NbDims, index};        
    end
    s.type = '()';
    y = subsasgn(y, s, dataa + datab);
end