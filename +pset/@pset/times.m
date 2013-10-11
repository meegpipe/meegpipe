function y = times(a, b)
% .* pset multiplication.
%
%   A.*B denotes element-by-element multiplication.
%
% See also: pset.pset

import misc.ispset;

% Check data dimensions
if ~all(size(a)==size(b)) && ~((prod(size(a))==1) || prod(size(b))==1), %#ok<PSIZE>
    error('pset.pset:times:dimensionMismatch', 'Data dimensions do not match.');
end

if ~ispset(a),
    tmp = a;
    a = b;
    b = tmp;
end

if a.NbChunks > 1,
    y = copy(a);
    y.Writable = true;
else
    y = nan(size(a,1),size(a,2),a.Precision);
end
for i = 1:a.NbChunks
    [index, dataa] = get_chunk(a, i);
    if ispset(b),
        [~,datab] = get_chunk(b, i);
    else
        if numel(b)<2,
            datab = b(1);
        else
            if a.Transposed,
                datab = b(index, :);
            else
                datab = b(:, index);
            end
        end
    end
    if a.Transposed,
        s.subs = {index, 1:a.NbDims};
    else
        s.subs = {1:a.NbDims, index};
    end
    s.type = '()';
    y = subsasgn(y, s, dataa .* datab);
end
if ispset(y)
    y.Writable = a.Writable;
end