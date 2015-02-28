function y = decimate(obj, factor, output_pset, varargin)

import pset.pset
import misc.process_arguments
import misc.eta

opt.verbose = is_verbose(obj);
[~, opt] = process_arguments(opt, varargin);


if nargin < 3,
    output_pset = [];
end

transposed_flag = false;
if obj.Transposed,
    obj.Transposed = false;
    transposed_flag = true;
end

if isempty(output_pset),
    y = pset.nan(size(obj,1), floor(size(obj,2)/factor));
    y.Writable = obj.Writable;
    y.Temporary = true;
else
    y = output_pset;
end

count = 0;
s.type = '()';
if opt.verbose,
    tinit = tic;
end
for i = 1:obj.NbChunks
    [~, data] = get_chunk(obj, i);
    data = data(:, 1:factor:end);
    s.subs = {1:size(data,1), count+1:count+size(data,2)};
    y = subsasgn(y, s, data);
    count = count + size(data,2);
    if opt.verbose,
        eta(tinit, obj.NbChunks, i);
    end
end

if transposed_flag,
    obj.Transposed = true;    
    y.Transposed = true;
end


end